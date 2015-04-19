--Example 1--
SELECT bl.pid AS blocked_pid
 ,a.usename AS blocked_user
 ,ka.current_query AS blocking_statement
 ,now() - ka.query_start AS blocking_duration
 ,kl.pid AS blocking_pid
 ,ka.usename AS blocking_user
 ,a.current_query AS blocked_statement
 ,now() - a.query_start AS blocked_duration
FROM pg_catalog.pg_locks bl
JOIN pg_catalog.pg_stat_activity a ON bl.pid = a.procpid
JOIN pg_catalog.pg_locks kl
JOIN pg_catalog.pg_stat_activity ka ON kl.pid = ka.procpid ON bl.transactionid = kl.transactionid
 AND bl.pid != kl.pid WHERE NOT bl.granted;

--Example 2--
SELECT l.mode
 ,d.datname
 ,c.relname
 ,l.granted
 ,l.transactionid
FROM pg_locks AS l
LEFT JOIN pg_database AS d ON l.DATABASE = d.oid
LEFT JOIN pg_class AS c ON l.relation = c.oid;