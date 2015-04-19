--Example 1--
SELECT a.indrelid::regclass
 ,a.indexrelid::regclass
 ,b.indexrelid::regclass
FROM (
 SELECT *
  ,array_to_string(indkey, ' ') AS cols
 FROM pg_index
 ) a
JOIN (
 SELECT *
  ,array_to_string(indkey, ' ') AS cols
 FROM pg_index
 ) b ON a.indrelid = b.indrelid
 AND a.indexrelid > b.indexrelid
 AND (
  (
   a.cols LIKE b.cols || '%'
   AND coalesce(substr(a.cols, length(b.cols) + 1, 1), ' ') = ' '
   )
  OR (
   b.cols LIKE a.cols || '%'
   AND coalesce(substr(b.cols, length(a.cols) + 1, 1), ' ') = ' '
   )
  )
ORDER BY indrelid;

--Example 2--
SELECT pg_size_pretty(sum(pg_relation_size(idx))::BIGINT) AS size
 ,(array_agg(idx)) [1] AS idx1
 ,(array_agg(idx)) [2] AS idx2
 ,(array_agg(idx)) [3] AS idx3
 ,(array_agg(idx)) [4] AS idx4
FROM (
 SELECT indexrelid::regclass AS idx
  ,(indrelid::TEXT || E '\n' || indclass::TEXT || E '\n' || indkey::TEXT || E '\n' || coalesce(indexprs::TEXT, '') || E '\n' || coalesce(indpred::TEXT, '')) AS KEY
 FROM pg_index
 ) sub
GROUP BY KEY
HAVING count(*) > 1
ORDER BY sum(pg_relation_size(idx)) DESC;

--Example 3--
SELECT string_agg(indexrelid::regclass::text,';') AS Idx, 
       (indrelid::text ||E'\n'|| indclass::text ||E'\n'|| indkey::text ||E'\n'|| coalesce(indexprs::text,'')||E'\n' || coalesce(indpred::text,'')) AS CompositeKey, 
       count(*) AS TotalCount
    FROM pg_index GROUP BY CompositeKey HAVING count(*) > 1;

--Example 4--
CREATE AGGREGATE array_accum (anyelement) (
 sfunc = array_append
 ,stype = anyarray
 ,initcond = '{}'
 );

SELECT indrelid::regclass
 ,array_accum(indexrelid::regclass)
FROM pg_index
GROUP BY indrelid
 ,indkey
HAVING count(*) > 1;

--Example 5--
 
WITH index_cols_ord as (
    SELECT attrelid, attnum, attname
    FROM pg_attribute
        JOIN pg_index ON indexrelid = attrelid
    WHERE indkey[0] > 0
    ORDER BY attrelid, attnum
),
index_col_list AS (
    SELECT attrelid,
        array_agg(attname) as cols
    FROM index_cols_ord
    GROUP BY attrelid
),
dup_natts AS (
SELECT indrelid, indexrelid
FROM pg_index as ind
WHERE EXISTS ( SELECT 1
    FROM pg_index as ind2
    WHERE ind.indrelid = ind2.indrelid
    AND ( ind.indkey @> ind2.indkey
     OR ind.indkey <@ ind2.indkey )
    AND ind.indkey[0] = ind2.indkey[0]
    AND ind.indkey <> ind2.indkey
    AND ind.indexrelid <> ind2.indexrelid
) )
SELECT userdex.schemaname as schema_name,
    userdex.relname as table_name,
    userdex.indexrelname as index_name,
    array_to_string(cols, ', ') as index_cols,
    indexdef,
    idx_scan as index_scans
FROM pg_stat_user_indexes as userdex
    JOIN index_col_list ON index_col_list.attrelid = userdex.indexrelid
    JOIN dup_natts ON userdex.indexrelid = dup_natts.indexrelid
    JOIN pg_indexes ON userdex.schemaname = pg_indexes.schemaname
        AND userdex.indexrelname = pg_indexes.indexname
ORDER BY userdex.schemaname, userdex.relname, cols, userdex.indexrelname;
