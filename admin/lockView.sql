--Root View--
CREATE VIEW lockview
AS
SELECT pid
 ,virtualtransaction AS vxid
 ,locktype AS lock_type
 ,mode AS lock_mode
 ,granted
 ,CASE 
  WHEN virtualxid IS NOT NULL
   AND transactionid IS NOT NULL
   THEN virtualxid || ' ' || transactionid
  WHEN virtualxid::TEXT IS NOT NULL
   THEN virtualxid
  ELSE transactionid::TEXT
  END AS xid_lock
 ,relname
 ,page
 ,tuple
 ,classid
 ,objid
 ,objsubid
FROM pg_locks
LEFT OUTER JOIN pg_class ON (pg_locks.relation = pg_class.oid)
WHERE pid != pg_backend_pid()
 AND virtualtransaction IS DISTINCT
FROM virtualxid
ORDER BY 1
 ,2
 ,5 DESC
 ,6
 ,3
 ,4
 ,7;

--Child View1--
CREATE VIEW lockview1
AS
SELECT pid
 ,vxid
 ,lock_type
 ,lock_mode
 ,granted
 ,xid_lock
 ,relname
FROM lockview
ORDER BY 1
 ,2
 ,5 DESC
 ,6
 ,3
 ,4
 ,7;

--Child View2--
CREATE VIEW lockview2
AS
SELECT pid
 ,vxid
 ,lock_type
 ,page
 ,tuple
 ,classid
 ,objid
 ,objsubid
FROM lockview
ORDER BY 1
 ,2
 ,granted DESC
 ,vxid
 ,xid_lock::TEXT
 ,3
 ,4
 ,5
 ,6
 ,7
 ,8;

--Child View3--
CREATE VIEW lockinfo_hierarchy
AS
WITH RECURSIVE lockinfo1
AS (
 SELECT pid
  ,vxid
  ,granted
  ,xid_lock
  ,lock_type
  ,relname
  ,page
  ,tuple
 FROM lockview
 WHERE xid_lock IS NOT NULL
  AND relname IS NULL
  AND granted
 
 UNION ALL
 
 SELECT lockview.pid
  ,lockview.vxid
  ,lockview.granted
  ,lockview.xid_lock
  ,lockview.lock_type
  ,lockview.relname
  ,lockview.page
  ,lockview.tuple
 FROM lockinfo1
 JOIN lockview ON (lockinfo1.xid_lock = lockview.xid_lock)
 WHERE lockview.xid_lock IS NOT NULL
  AND lockview.relname IS NULL
  AND NOT lockview.granted
  AND lockinfo1.granted
 )
 ,lockinfo2
AS (
 SELECT pid
  ,vxid
  ,granted
  ,xid_lock
  ,lock_type
  ,relname
  ,page
  ,tuple
 FROM lockview
 WHERE lock_type = ’tuple’
  AND granted
 
 UNION ALL
 
 SELECT lockview.pid
  ,lockview.vxid
  ,lockview.granted
  ,lockview.xid_lock
  ,lockview.lock_type
  ,lockview.relname
  ,lockview.page
  ,lockview.tuple
 FROM lockinfo2
 JOIN lockview ON (
   lockinfo2.lock_type = lockview.lock_type
   AND lockinfo2.relname = lockview.relname
   AND lockinfo2.page = lockview.page
   AND lockinfo2.tuple = lockview.tuple
   )
 WHERE lockview.lock_type = ’tuple’
  AND NOT lockview.granted
  AND lockinfo2.granted
 )
SELECT *
FROM lockinfo1

UNION ALL

SELECT *
FROM lockinfo2;

--Child View4--
CREATE VIEW lock_stat_view
AS
SELECT pg_stat_activity.procpid AS pid
 ,current_query
 ,waiting
 ,vxid
 ,lock_type
 ,lock_mode
 ,granted
 ,xid_lock
FROM lockview
JOIN pg_stat_activity ON (lockview.pid = pg_stat_activity.procpid);