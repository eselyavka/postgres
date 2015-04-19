--Example 1--
WITH btree_index_atts
AS (
 SELECT nspname
  ,relname
  ,reltuples
  ,relpages
  ,indrelid
  ,relam
  ,regexp_split_to_table(indkey::TEXT, ' ')::SMALLINT AS attnum
  ,indexrelid AS index_oid
 FROM pg_index
 JOIN pg_class ON pg_class.oid = pg_index.indexrelid
 JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
 JOIN pg_am ON pg_class.relam = pg_am.oid
 WHERE pg_am.amname = 'btree'
 )
 ,index_item_sizes
AS (
 SELECT i.nspname
  ,i.relname
  ,i.reltuples
  ,i.relpages
  ,i.relam
  ,s.starelid
  ,a.attrelid AS table_oid
  ,index_oid
  ,current_setting('block_size')::NUMERIC AS bs
  ,
  /* MAXALIGN: 4 on 32bits, 8 on 64bits (and mingw32 ?) */
  CASE 
   WHEN version() ~ 'mingw32'
    OR version() ~ '64-bit'
    THEN 8
   ELSE 4
   END AS maxalign
  ,24 AS pagehdr
  ,
  /* per tuple header: add index_attribute_bm if some cols are null-able */
  CASE 
   WHEN max(coalesce(s.stanullfrac, 0)) = 0
    THEN 2
   ELSE 6
   END AS index_tuple_hdr
  ,
  /* data len: we remove null values save space using it fractionnal part from stats */
  sum((1 - coalesce(s.stanullfrac, 0)) * coalesce(s.stawidth, 2048)) AS nulldatawidth
 FROM pg_attribute AS a
 JOIN pg_statistic AS s ON s.starelid = a.attrelid
  AND s.staattnum = a.attnum
 JOIN btree_index_atts AS i ON i.indrelid = a.attrelid
  AND a.attnum = i.attnum
 WHERE a.attnum > 0
 GROUP BY 1
  ,2
  ,3
  ,4
  ,5
  ,6
  ,7
  ,8
  ,9
 )
 ,index_aligned
AS (
 SELECT maxalign
  ,bs
  ,nspname
  ,relname AS index_name
  ,reltuples
  ,relpages
  ,relam
  ,table_oid
  ,index_oid
  ,(
   2 + maxalign - CASE /* Add padding to the index tuple header to align on MAXALIGN */
    WHEN 2 % maxalign = 0
     THEN maxalign
    ELSE 2 % maxalign
    END + nulldatawidth + maxalign - CASE /* Add padding to the data to align on MAXALIGN */
    WHEN nulldatawidth::INTEGER % maxalign = 0
     THEN maxalign
    ELSE nulldatawidth::INTEGER % maxalign
    END
   )::NUMERIC AS nulldatahdrwidth
  ,pagehdr
 FROM index_item_sizes AS s1
 )
 ,otta_calc
AS (
 SELECT bs
  ,nspname
  ,table_oid
  ,index_oid
  ,index_name
  ,relpages
  ,coalesce(ceil((reltuples * (4 + nulldatahdrwidth)) / (bs - pagehdr::FLOAT)) + CASE 
    WHEN am.amname IN (
      'hash'
      ,'btree'
      )
     THEN 1
    ELSE 0
    END, 0 /* btree and hash have a metadata reserved block */
  ) AS otta
 FROM index_aligned AS s2
 LEFT JOIN pg_am am ON s2.relam = am.oid
 )
 ,raw_bloat
AS (
 SELECT current_database() AS dbname
  ,nspname
  ,c.relname AS table_name
  ,index_name
  ,bs * (sub.relpages)::BIGINT AS totalbytes
  ,CASE 
   WHEN sub.relpages <= otta
    THEN 0
   ELSE bs * (sub.relpages - otta)::BIGINT
   END AS wastedbytes
  ,CASE 
   WHEN sub.relpages <= otta
    THEN 0
   ELSE bs * (sub.relpages - otta)::BIGINT * 100 / (bs * (sub.relpages)::BIGINT)
   END AS realbloat
  ,pg_relation_size(sub.table_oid) AS table_bytes
  ,stat.idx_scan AS index_scans
 FROM otta_calc AS sub
 JOIN pg_class AS c ON c.oid = sub.table_oid
 JOIN pg_stat_user_indexes AS stat ON sub.index_oid = stat.indexrelid
 )
SELECT dbname AS database_name
 ,nspname AS schema_name
 ,table_name
 ,index_name
 ,round(realbloat, 1) AS bloat_pct
 ,wastedbytes AS bloat_bytes
 ,pg_size_pretty(wastedbytes::BIGINT) AS bloat_size
 ,totalbytes AS index_bytes
 ,pg_size_pretty(totalbytes::BIGINT) AS index_size
 ,table_bytes
 ,pg_size_pretty(table_bytes::BIGINT) AS table_size
 ,index_scans
FROM raw_bloat
WHERE (
  realbloat > 50
  AND wastedbytes > 50000000
  )
ORDER BY wastedbytes DESC;

--Example 2--
-- WARNING: executed with a non-superuser role, the query inspect only index on tables you are granted to read.
-- WARNING: rows with is_na = 't' are known to have bad statistics ("name" type is not supported).
-- This query is compatible with PostgreSQL 8.2 and after
SELECT current_database()
 ,nspname AS schemaname
 ,tblname
 ,idxname
 ,bs * (sub.relpages)::BIGINT AS real_size
 ,bs * est_pages::BIGINT AS estimated_size
 ,bs * (sub.relpages - est_pages)::BIGINT AS bloat_size
 ,100 * (sub.relpages - est_pages)::FLOAT / sub.relpages AS bloat_ratio
 ,is_na
-- , 100-(sub.pst).avg_leaf_density, est_pages, index_tuple_hdr_bm, maxalign, pagehdr, nulldatawidth, nulldatahdrwidth, sub.reltuples, sub.relpages -- (DEBUG INFO)
FROM (
 SELECT bs
  ,nspname
  ,table_oid
  ,tblname
  ,idxname
  ,relpages
  ,coalesce(1 + ceil(reltuples / floor((bs - pageopqdata - pagehdr) / (4 + nulldatahdrwidth)::FLOAT)), 0 -- ItemIdData size + computed avg size of a tuple (nulldatahdrwidth)
  ) AS est_pages
  ,is_na
 -- , stattuple.pgstatindex(quote_ident(nspname)||'.'||quote_ident(idxname)) AS pst, index_tuple_hdr_bm, maxalign, pagehdr, nulldatawidth, nulldatahdrwidth, reltuples -- (DEBUG INFO)
 FROM (
  SELECT maxalign
   ,bs
   ,nspname
   ,tblname
   ,idxname
   ,reltuples
   ,relpages
   ,relam
   ,table_oid
   ,(
    index_tuple_hdr_bm + maxalign - CASE -- Add padding to the index tuple header to align on MAXALIGN
     WHEN index_tuple_hdr_bm % maxalign = 0
      THEN maxalign
     ELSE index_tuple_hdr_bm % maxalign
     END + nulldatawidth + maxalign - CASE -- Add padding to the data to align on MAXALIGN
     WHEN nulldatawidth = 0
      THEN 0
     WHEN nulldatawidth::INTEGER % maxalign = 0
      THEN maxalign
     ELSE nulldatawidth::INTEGER % maxalign
     END
    )::NUMERIC AS nulldatahdrwidth
   ,pagehdr
   ,pageopqdata
   ,is_na
  -- , index_tuple_hdr_bm, nulldatawidth -- (DEBUG INFO)
  FROM (
   SELECT i.nspname
    ,i.tblname
    ,i.idxname
    ,i.reltuples
    ,i.relpages
    ,i.relam
    ,a.attrelid AS table_oid
    ,current_setting('block_size')::NUMERIC AS bs
    ,CASE -- MAXALIGN: 4 on 32bits, 8 on 64bits (and mingw32 ?)
     WHEN version() ~ 'mingw32'
      OR version() ~ '64-bit|x86_64|ppc64|ia64|amd64'
      THEN 8
     ELSE 4
     END AS maxalign
    ,
    /* per page header, fixed size: 20 for 7.X, 24 for others */
    24 AS pagehdr
    ,
    /* per page btree opaque data */
    16 AS pageopqdata
    ,
    /* per tuple header: add IndexAttributeBitMapData if some cols are null-able */
    CASE 
     WHEN max(coalesce(s.null_frac, 0)) = 0
      THEN 2 -- IndexTupleData size
     ELSE 2 + ((32 + 8 - 1) / 8) -- IndexTupleData size + IndexAttributeBitMapData size ( max num filed per index + 8 - 1 /8)
     END AS index_tuple_hdr_bm
    ,
    /* data len: we remove null values save space using it fractionnal part from stats */
    sum((1 - coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 1024)) AS nulldatawidth
    ,max(CASE 
      WHEN a.atttypid = 'pg_catalog.name'::regtype
       THEN 1
      ELSE 0
      END) > 0 AS is_na
   FROM pg_attribute AS a
   JOIN (
    SELECT nspname
     ,tbl.relname AS tblname
     ,idx.relname AS idxname
     ,idx.reltuples
     ,idx.relpages
     ,idx.relam
     ,indrelid
     ,indexrelid
     ,indkey::SMALLINT [] AS attnum
    FROM pg_index
    JOIN pg_class idx ON idx.oid = pg_index.indexrelid
    JOIN pg_class tbl ON tbl.oid = pg_index.indrelid
    JOIN pg_namespace ON pg_namespace.oid = idx.relnamespace
    WHERE pg_index.indisvalid
     AND tbl.relkind = 'r'
     AND pg_namespace.nspname NOT IN (
      'information_schema'
      ,'pg_catalog'
      )
    ) AS i ON a.attrelid = i.indexrelid
   JOIN pg_stats AS s ON s.schemaname = i.nspname
    AND (
     (
      s.tablename = i.tblname
      AND s.attname = pg_catalog.pg_get_indexdef(a.attrelid, a.attnum, TRUE)
      ) -- stats from tbl
     OR (
      s.tablename = i.idxname
      AND s.attname = a.attname
      )
     ) -- stats from functionnal cols
   JOIN pg_type AS t ON a.atttypid = t.oid
   WHERE a.attnum > 0
   GROUP BY 1
    ,2
    ,3
    ,4
    ,5
    ,6
    ,7
    ,8
    ,9
   ) AS s1
  ) AS s2
 JOIN pg_am am ON s2.relam = am.oid
 WHERE am.amname = 'btree'
 ) AS sub
-- WHERE NOT is_na
ORDER BY 2
 ,3
 ,4;

--Example 3--
SELECT relname
 ,pg_table_size(oid) AS index_size
 ,100 - (pgstatindex(relname)).avg_leaf_density AS bloat_ratio
FROM pg_class
WHERE relname ~ 'test'
 AND relkind = 'i'
ORDER BY 1;
