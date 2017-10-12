-- leetcode.com #626

/*
seat
+---------+---------+
|    id   | student |
+---------+---------+
|    1    | Abbot   |
|    2    | Doris   |
|    3    | Emerson |
|    4    | Green   |
|    5    | Jeames  |
+---------+---------+

+---------+---------+
|    id   | student |
+---------+---------+
|    1    | Doris   |
|    2    | Abbot   |
|    3    | Green   |
|    4    | Emerson |
|    5    | Jeames  |
+---------+---------+
*/

SELECT row_number() over() AS id,
       student
FROM
  (SELECT CASE
              WHEN id % 2 = 0 THEN coalesce(
                                              (SELECT student
                                               FROM seat sint
                                               WHERE sint.id=s.id - 1))
              ELSE coalesce(
                              (SELECT student
                               FROM seat sint
                               WHERE sint.id=s.id + 1),
                              (SELECT student
                               FROM seat sint
                               WHERE sint.id=s.id))
          END AS student
   FROM seat s) t;
