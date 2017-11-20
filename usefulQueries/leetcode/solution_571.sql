-- leetcode.com #571

/*
Numbers
+----------+-------------+
|  Number  |  Frequency  |
+----------+-------------|
|  0       |  7          |
|  1       |  1          |
|  2       |  3          |
|  3       |  1          |
+----------+-------------+

0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 2, 3 = (0 + 0) / 2 = 0

Output
+--------+
| median |
+--------|
| 0.0000 |
+--------+
+-----+------------+--------+
*/

WITH fin AS
  (WITH res AS
     (SELECT array_agg(number) AS elements
      FROM
        (SELECT number, -1 + row_number() over() AS row_num
         FROM
           (SELECT number,generate_series(1,frequency)
            FROM numbers n) t) tt
      WHERE row_num=
          (SELECT sum(frequency)
           FROM numbers)/2
        OR row_num=(
                      (SELECT sum(frequency)
                       FROM numbers) - 1)/2) SELECT CASE
                                                        WHEN array_length(elements::int[], 1) > 1 THEN unnest(elements)
                                                        ELSE unnest(elements || elements)
                                                    END AS elem
   FROM res)
SELECT CAST(sum(elem)/2.0 AS numeric(10,4))
FROM fin;
