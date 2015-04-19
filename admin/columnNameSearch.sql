SELECT *
FROM information_schema.columns
WHERE table_schema = 'public'
 AND column_name ilike '%<pattern>%'
