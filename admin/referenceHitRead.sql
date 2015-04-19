SELECT datname
 ,CASE 
  WHEN blks_read = 0
   THEN 0
  ELSE blks_hit / blks_read
  END AS ratio
FROM pg_stat_database;
