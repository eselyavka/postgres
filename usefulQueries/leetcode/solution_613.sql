-- leetcode.com #613
/*
point
┌────┐
│ x  │
├────┤
│ -1 │
│  0 │
│  2 │
└────┘
┌──────────┐
│ shortest │
├──────────┤
│        1 │
└──────────┘
*/

WITH res AS
  (WITH rows_with_ids AS
     (SELECT x,
             row_number() over()
      FROM point ORDER BY x) SELECT (t1.x - t2.x) AS diff
   FROM rows_with_ids AS t1
   JOIN rows_with_ids AS t2 ON t1.row_number=t2.row_number+1)
SELECT min(abs(diff)) AS shortest
FROM res;
