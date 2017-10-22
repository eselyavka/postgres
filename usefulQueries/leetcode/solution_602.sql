-- leetcode.com #602

/*
request_accepted
| requester_id | accepter_id | accept_date|
|--------------|-------------|------------|
| 1            | 2           | 2016_06-03 |
| 1            | 3           | 2016-06-08 |
| 2            | 3           | 2016-06-08 |
| 3            | 4           | 2016-06-09 |

| id | num |
|----|-----|
| 3  | 3   |
*/

SELECT aid AS id,
       num
FROM
  (SELECT aid,
          sum(cnt) AS num
   FROM
     (SELECT accepter_id AS aid,
             count(*) AS cnt
      FROM request_accepted
      GROUP BY accepter_id
      UNION ALL SELECT requester_id,
                       count(*)
      FROM request_accepted
      GROUP BY requester_id) u
   GROUP BY aid) res
ORDER BY num DESC
LIMIT 1;
