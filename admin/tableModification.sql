SELECT relname
 ,n_tup_ins
 ,n_tup_upd
 ,n_tup_del
FROM pg_stat_user_tables
ORDER BY n_tup_upd DESC;
