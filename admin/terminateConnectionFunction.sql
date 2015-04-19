DROP FUNCTION IF EXISTS drop_connection(VARCHAR(50));
 CREATE FUNCTION drop_connection (VARCHAR(50))
 RETURNS void
 AS
 $$

 DECLARE dbname ALIAS
 FOR $1;

 r RECORD;

 BEGIN
  --  RAISE NOTICE '%', dbname;
  FOR r IN

  SELECT procpid
  FROM pg_stat_activity
  WHERE datname LIKE dbname LOOP PERFORM pg_terminate_backend(r.procpid);
 END

 LOOP;END;$$

 LANGUAGE plpgsql;