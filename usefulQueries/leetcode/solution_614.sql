-- leetcode.com #614

/*
follow
+-------------+------------+
| followee    | follower   |
+-------------+------------+
|     A       |     B      |
|     B       |     C      |
|     B       |     D      |
|     D       |     E      |
+-------------+------------+

+-------------+------------+
| follower    | num        |
+-------------+------------+
|     B       |  2         |
|     D       |  1         |
+-------------+------------+
*/

SELECT t1.follower,
       count(DISTINCT t2.follower) AS num
FROM follow t1
INNER JOIN follow t2 ON t1.follower = t2.followee
GROUP BY t1.follower
ORDER BY 1;
