CREATE OR REPLACE FUNCTION restoreTable( corruptedTableName name, salvagedTableName name )
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
 corruptedTableName ALIAS FOR $1;
 salvagedTableName ALIAS FOR $2;
 pageCount int;
 pageIterator int;
 tupleIterator int;
 tupleCount int;
 isCorruptedTableExists boolean;
 isSalvagedTableExists boolean;
 pos tid;
BEGIN
  tupleCount = 65535;
  SELECT exists (SELECT 1 FROM pg_class WHERE relname = quote_ident(corruptedTableName)) INTO isCorruptedTableExists;
  SELECT exists (SELECT 1 FROM pg_class WHERE relname = quote_ident(salvagedTableName)) INTO isSalvagedTableExists;
  IF isCorruptedTableExists = false THEN
    RAISE WARNING 'No corrupted table: % found',corruptedTableName;
    RETURN;
  ELSE
    RAISE NOTICE 'Corrupted table: % exists', corruptedTableName;
  END IF;
  IF isSalvagedTableExists = false THEN
    EXECUTE 'CREATE TABLE ' || salvagedTableName  || ' AS TABLE ' || corruptedTableName || ' WITH NO DATA';
    RAISE NOTICE 'Creating salvaged table: %', salvagedTableName;
  ELSE
    RAISE NOTICE 'Salvaged table: % exists', salvagedTableName;
  END IF;
  SELECT relpages INTO pageCount FROM pg_class WHERE relname = quote_ident(corruptedTableName) AND relkind = 'r';
  <<pageloop>> 
  FOR pageIterator IN 0..pageCount LOOP
    FOR tupleIterator IN 1..tupleCount LOOP
      pos = ('(' || pageIterator || ',' || tupleIterator || ')')::tid;
      BEGIN
        EXECUTE 'INSERT INTO ' || salvagedTableName || ' SELECT * FROM ' || corruptedTableName || ' WHERE ctid = $1' USING pos;
      EXCEPTION
        WHEN sqlstate 'XX001' THEN
          RAISE WARNING 'skipping page %', pageIterator;
          CONTINUE pageloop;
        WHEN OTHERS THEN
          RAISE WARNING 'skipping row %, SQLSTATE %', pos, SQLSTATE::text; 
      END;
    END LOOP;
  END LOOP;
END;
$function$;