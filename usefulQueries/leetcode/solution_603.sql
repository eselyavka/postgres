-- leetcode.com #603
/*
cinema
┌─────────┬──────┐
│ seat_id │ free │
├─────────┼──────┤
│       1 │ t    │
│       2 │ f    │
│       3 │ t    │
│       4 │ t    │
│       5 │ t    │
└─────────┴──────┘

┌─────────┐
│ seat_id │
├─────────┤
│       3 │
│       4 │
│       5 │
└─────────┘
*/
SELECT seat_id
FROM
  (SELECT t1.seat_id
   FROM cinema t1,
        cinema t2
   WHERE t1.seat_id=t2.seat_id+1
     AND (t1.free
          AND t2.free)
   UNION SELECT t2.seat_id
   FROM cinema t1,
        cinema t2
   WHERE t1.seat_id=t2.seat_id+1
     AND (t1.free
          AND t2.free)) t
ORDER BY seat_id;
