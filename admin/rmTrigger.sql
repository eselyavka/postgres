CREATE FUNCTION rmTrigger ()
RETURNS void
AS
$$

DECLARE trows RECORD;

BEGIN
 FOR trows IN

 SELECT tgname
  ,relname
 FROM pg_trigger
 INNER JOIN pg_stat_all_tables ON pg_stat_all_tables.relid = pg_trigger.tgrelid
  AND pg_trigger.tgtype IN (
   29
   ,60
   )
 ORDER BY pg_stat_all_tables.relname LOOP

 -- RAISE NOTICE 'DROP TRIGGER IF EXISTS %s ON %s', quote_ident(trows.tgname), quote_ident(trows.relname);
 EXECUTE 'DROP TRIGGER IF EXISTS ' || trows.tgname || ' ON ' || trows.relname;
END

LOOP;END;$$

LANGUAGE plpgsql;