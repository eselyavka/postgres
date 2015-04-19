WITH f (NAME)
AS (
 VALUES ('pg_hba.conf')
 )
SELECT pg_catalog.pg_read_file(NAME, 0, (pg_catalog.pg_stat_file(NAME)).size)
FROM f;

SELECT *
FROM pg_catalog.pg_read_file('pg_hba.conf');