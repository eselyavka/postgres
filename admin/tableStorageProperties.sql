SELECT n.nspname
 ,c.relname
 ,pg_catalog.array_to_string(c.reloptions || array(SELECT 'toast.' || x FROM pg_catalog.unnest(tc.reloptions) x), ', ') AS relopts
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_class tc ON (c.reltoastrelid = tc.oid)
JOIN pg_namespace n ON c.relnamespace = n.oid
 AND n.nspname NOT IN (
  'information_schema'
  ,'pg_catalog'
  )
WHERE c.relkind = 'r'
