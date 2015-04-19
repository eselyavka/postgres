-- Example 1 --
SELECT c.relname
 ,pg_size_pretty(count(*) * 8192) AS buffered
 ,round(100.0 * count(*) / (
   SELECT setting
   FROM pg_settings
   WHERE NAME = 'shared_buffers'
   )::INTEGER, 1) AS buffers_percent
 ,round(100.0 * count(*) * 8192 / pg_relation_size(c.oid), 1) AS percent_of_relation
FROM pg_class c
INNER JOIN pg_buffercache b ON b.relfilenode = c.relfilenode
INNER JOIN pg_database d ON (
  b.reldatabase = d.oid
  AND d.datname = current_database()
  )
INNER JOIN pg_namespace n ON (c.relnamespace = n.oid)
WHERE n.nspname NOT IN (
  'pg_catalog'
  ,'information_schema'
  )
GROUP BY c.oid
 ,c.relname
ORDER BY 3 DESC LIMIT 10;

-- Example 2 --
SELECT pg_size_pretty(count(*) * 8192) as ideal_shared_buffers
 FROM pg_class c
 INNER JOIN pg_buffercache b ON b.relfilenode = c.relfilenode
 INNER JOIN pg_database d ON (b.reldatabase = d.oid AND d.datname = current_database())
 WHERE usagecount >= 3;
