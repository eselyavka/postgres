SELECT table_name
 ,data_type
 ,count(*) AS col
FROM information_schema.columns
WHERE table_name IN (
  SELECT tablename
  FROM pg_tables
  WHERE schemaname = 'public'
  )
 AND data_type = 'text'
GROUP BY table_name
 ,data_type
ORDER BY count(*) DESC