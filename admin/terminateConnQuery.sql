SELECT pg_terminate_backend(procpid)
FROM pg_stat_activity
WHERE datname = 'dbname';