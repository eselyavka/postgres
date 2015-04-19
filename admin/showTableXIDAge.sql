--Example 1--
SELECT c.oid::regclass AS table_name
 ,greatest(age(c.relfrozenxid), age(t.relfrozenxid)) AS age
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
 AND n.nspname NOT IN (
  'information_schema'
  ,'pg_catalog'
  )
LEFT JOIN pg_class t ON c.reltoastrelid = t.oid
WHERE c.relkind = 'r'
ORDER BY age DESC;

--Example 2--
SELECT relname
 ,age(relfrozenxid) AS xid_age
 ,pg_size_pretty(pg_table_size(oid)) AS table_size
FROM pg_class
WHERE relkind = 'r'
 AND pg_table_size(oid) > 1073741824
ORDER BY age(relfrozenxid) DESC LIMIT 20;

--Example 3--
SELECT datname
 ,age(datfrozenxid)
FROM pg_database;
