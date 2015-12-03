--find in http://www.cybertec.at/2015/11/flexible-grouping-some-dirty-sql-trickery/
SELECT x.*,
       sum(edge) over (
                       ORDER BY t) AS group_num
FROM
  (SELECT *,
          CASE
              WHEN (t - lag(t,1) over (
                                       ORDER BY t)) >= '10 minutes' THEN 1
              ELSE 0
          END AS edge
   FROM t_data) x
ORDER BY t;
