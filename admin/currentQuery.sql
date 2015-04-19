SELECT datname
 ,NOW() - query_start AS duration
 ,procpid
 ,current_query
FROM pg_stat_activity
ORDER BY duration DESC;
