--Example 1--
SELECT current_database()
 ,schemaname
 ,tablename
 ,/*reltuples::bigint, relpages::bigint, otta,*/
 ROUND(CASE 
   WHEN otta = 0
    THEN 0.0
   ELSE sml.relpages / otta::NUMERIC
   END, 1) AS tbloat
 ,CASE 
  WHEN relpages < otta
   THEN 0
  ELSE bs * (sml.relpages - otta)::BIGINT
  END AS wastedbytes
 ,iname
 ,/*ituples::bigint, ipages::bigint, iotta,*/
 ROUND(CASE 
   WHEN iotta = 0
    OR ipages = 0
    THEN 0.0
   ELSE ipages / iotta::NUMERIC
   END, 1) AS ibloat
 ,CASE 
  WHEN ipages < iotta
   THEN 0
  ELSE bs * (ipages - iotta)
  END AS wastedibytes
FROM (
 SELECT schemaname
  ,tablename
  ,cc.reltuples
  ,cc.relpages
  ,bs
  ,CEIL((
    cc.reltuples * (
     (
      datahdr + ma - (
       CASE 
        WHEN datahdr % ma = 0
         THEN ma
        ELSE datahdr % ma
        END
       )
      ) + nullhdr2 + 4
     )
    ) / (bs - 20::FLOAT)) AS otta
  ,COALESCE(c2.relname, '?') AS iname
  ,COALESCE(c2.reltuples, 0) AS ituples
  ,COALESCE(c2.relpages, 0) AS ipages
  ,COALESCE(CEIL((c2.reltuples * (datahdr - 12)) / (bs - 20::FLOAT)), 0) AS iotta /* very rough approximation, assumes all cols */
 FROM (
  SELECT ma
   ,bs
   ,schemaname
   ,tablename
   ,(
    datawidth + (
     hdr + ma - (
      CASE 
       WHEN hdr % ma = 0
        THEN ma
       ELSE hdr % ma
       END
      )
     )
    )::NUMERIC AS datahdr
   ,(
    maxfracsum * (
     nullhdr + ma - (
      CASE 
       WHEN nullhdr % ma = 0
        THEN ma
       ELSE nullhdr % ma
       END
      )
     )
    ) AS nullhdr2
  FROM (
   SELECT schemaname
    ,tablename
    ,hdr
    ,ma
    ,bs
    ,SUM((1 - null_frac) * avg_width) AS datawidth
    ,MAX(null_frac) AS maxfracsum
    ,hdr + (
     SELECT 1 + count(*) / 8
     FROM pg_stats s2
     WHERE null_frac <> 0
      AND s2.schemaname = s.schemaname
      AND s2.tablename = s.tablename
     ) AS nullhdr
   FROM pg_stats s
    ,(
     SELECT (
       SELECT current_setting('block_size')::NUMERIC
       ) AS bs
      ,CASE 
       WHEN substring(v, 12, 3) IN (
         '8.0'
         ,'8.1'
         ,'8.2'
         )
        THEN 27
       ELSE 23
       END AS hdr
      ,CASE 
       WHEN v ~ 'mingw32'
        THEN 8
       ELSE 4
       END AS ma
     FROM (
      SELECT version() AS v
      ) AS foo
     ) AS constants
   GROUP BY 1
    ,2
    ,3
    ,4
    ,5
   ) AS foo
  ) AS rs
 JOIN pg_class cc ON cc.relname = rs.tablename
 JOIN pg_namespace nn ON cc.relnamespace = nn.oid
  AND nn.nspname = rs.schemaname
  AND nn.nspname NOT IN (
   'information_schema'
   ,'pg_catalog'
   )
 LEFT JOIN pg_index i ON indrelid = cc.oid
 LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
 ) AS sml
ORDER BY wastedbytes DESC;

--Example 2--
SELECT pg_relation_size(relid) AS tablesize
 ,schemaname
 ,relname
 ,n_live_tup
FROM pg_stat_user_tables
WHERE relname = 'tablename';

--Example 3--
/* WARNING: executed with a non-superuser role, the query inspect only tables you are granted to read.
* This query is compatible with PostgreSQL 9.0 and more
* Changelog:
*   * exclude inherited stats
*/
SELECT current_database()
 ,schemaname
 ,tblname
 ,bs * tblpages AS real_size
 ,(tblpages - est_num_pages) * bs AS bloat_size
 ,tblpages
 ,is_na
 ,CASE 
  WHEN tblpages - est_num_pages > 0
   THEN 100 * (tblpages - est_num_pages) / tblpages::FLOAT
  ELSE 0
  END AS bloat_ratio
-- , (pst).free_percent + (pst).dead_tuple_percent AS real_frag
FROM (
 SELECT ceil(reltuples / ((bs - page_hdr) / tpl_size)) + ceil(toasttuples / 4) AS est_num_pages
  ,tblpages
  ,bs
  ,tblid
  ,schemaname
  ,tblname
  ,heappages
  ,toastpages
  ,is_na
 -- , stattuple.pgstattuple(tblid) AS pst
 FROM (
  SELECT (
    4 + tpl_hdr_size + tpl_data_size + (2 * ma) - CASE 
     WHEN tpl_hdr_size % ma = 0
      THEN ma
     ELSE tpl_hdr_size % ma
     END - CASE 
     WHEN ceil(tpl_data_size)::INT % ma = 0
      THEN ma
     ELSE ceil(tpl_data_size)::INT % ma
     END
    ) AS tpl_size
   ,bs - page_hdr AS size_per_block
   ,(heappages + toastpages) AS tblpages
   ,heappages
   ,toastpages
   ,reltuples
   ,toasttuples
   ,bs
   ,page_hdr
   ,tblid
   ,schemaname
   ,tblname
   ,is_na
  FROM (
   SELECT tbl.oid AS tblid
    ,ns.nspname AS schemaname
    ,tbl.relname AS tblname
    ,tbl.reltuples
    ,tbl.relpages AS heappages
    ,coalesce(toast.relpages, 0) AS toastpages
    ,coalesce(toast.reltuples, 0) AS toasttuples
    ,current_setting('block_size')::NUMERIC AS bs
    ,CASE 
     WHEN version() ~ 'mingw32'
      OR version() ~ '64-bit|x86_64|ppc64|ia64|amd64'
      THEN 8
     ELSE 4
     END AS ma
    ,24 AS page_hdr
    ,23 + CASE 
     WHEN MAX(coalesce(null_frac, 0)) > 0
      THEN (7 + count(*)) / 8
     ELSE 0::INT
     END + CASE 
     WHEN tbl.relhasoids
      THEN 4
     ELSE 0
     END AS tpl_hdr_size
    ,sum((1 - coalesce(s.null_frac, 0)) * coalesce(CASE 
       WHEN t.typlen = - 1
        THEN CASE 
          WHEN s.avg_width < 127
           THEN s.avg_width + 1
          ELSE s.avg_width + 4
          END
       WHEN t.typlen = - 2
        THEN s.avg_width + 1
       ELSE t.typlen
       END, 1024)) AS tpl_data_size
    ,bool_or(att.atttypid = 'pg_catalog.name'::regtype) AS is_na
   FROM pg_attribute AS att
   JOIN pg_type AS t ON att.atttypid = t.oid
   JOIN pg_class AS tbl ON att.attrelid = tbl.oid
   JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
   JOIN pg_stats AS s ON s.schemaname = ns.nspname
    AND s.tablename = tbl.relname
    AND s.inherited = false
    AND s.attname = att.attname
   LEFT JOIN pg_class AS toast ON tbl.reltoastrelid = toast.oid
   WHERE att.attnum > 0
    AND NOT att.attisdropped
    AND tbl.relkind = 'r'
    AND ns.nspname NOT IN (
     'information_schema'
     ,'pg_catalog'
     )
   GROUP BY 1
    ,2
    ,3
    ,4
    ,5
    ,6
    ,7
    ,8
    ,9
    ,10
    ,tbl.relhasoids
   ORDER BY 2
    ,3
   ) AS s
  ) AS s2
 ) AS s3
