SELECT relname
 ,seq_scan
 ,idx_scan
 ,CASE 
  WHEN idx_scan = 0
   THEN 100
  ELSE seq_scan / idx_scan
  END AS ratio
FROM pg_stat_user_tables
ORDER BY ratio DESC;
