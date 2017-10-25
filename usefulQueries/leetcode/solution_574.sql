-- leetcode.com #574

/*
Candidate
+-----+---------+
| id  | Name    |
+-----+---------+
| 1   | A       |
| 2   | B       |
| 3   | C       |
| 4   | D       |
| 5   | E       |
+-----+---------+

Vote
+-----+--------------+
| id  | CandidateId  |
+-----+--------------+
| 1   |     2        |
| 2   |     4        |
| 3   |     3        |
| 4   |     2        |
| 5   |     5        |
+-----+--------------+

+------+
| Name |
+------+
| B    |
+------+
*/

SELECT Name
FROM Candidate
WHERE id =
    (SELECT candidateid
     FROM
       (SELECT candidateid,
               count(*) AS cnt
        FROM vote
        GROUP BY candidateid
        ORDER BY 2 DESC
        LIMIT 1) t);
