SELECT c.oid::regclass AS table_name
 ,greatest(age(c.relfrozenxid), age(t.relfrozenxid)) AS age
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
LEFT JOIN pg_class t ON c.reltoastrelid = t.oid
WHERE c.relkind = 'r'
 AND n.nspname NOT IN (
  'pg_catalog'
  ,'information_schema'
  );
