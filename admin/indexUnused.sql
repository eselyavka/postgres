--Example 1--
SELECT indexrelid::regclass AS indexname
 ,relid::regclass AS tablename
FROM pg_stat_user_indexes
JOIN pg_index USING (indexrelid)
WHERE idx_scan = 0
 AND indisunique IS false;

--Example 2--
SELECT starelid::regclass
 ,indexrelid::regclass
 ,array_accum(staattnum)
 ,relpages
 ,reltuples
 ,array_accum(stadistinct)
FROM pg_index
JOIN pg_statistic ON (
  starelid = indrelid
  AND staattnum = ANY (indkey)
  )
JOIN pg_class ON (indexrelid = oid)
WHERE CASE 
  WHEN stadistinct < 0
   THEN stadistinct > - .8
  ELSE reltuples / stadistinct > .2
  END
 AND NOT (
  indisunique
  OR indisprimary
  )
 AND (
  relpages > 100
  OR reltuples > 1000
  )
GROUP BY starelid
 ,indexrelid
 ,relpages
 ,reltuples
ORDER BY starelid;
