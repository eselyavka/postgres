-- leetcode.com #178

/*
Scores
+----+-------+
| Id | Score |
+----+-------+
| 1  | 3.50  |
| 2  | 3.65  |
| 3  | 4.00  |
| 4  | 3.85  |
| 5  | 4.00  |
| 6  | 3.65  |
+----+-------+
*/

SELECT unnest(array_agg),
       rank
FROM
  (SELECT array_agg,
          rank() over (
                       ORDER BY array_agg DESC)
   FROM
     (SELECT array_agg(score)
      FROM scores
      GROUP BY score) AS t) AS t1;
