SELECT r,
       Sum(cnt)
FROM (
SELECT Textin(Record_out(ta)) AS r,
       1 AS cnt
FROM ta
UNION ALL
SELECT textin(Record_out(tb) AS r, -1 AS cnt
              FROM tb) foo
GROUP BY r
HAVING sum(cnt) <> 0;
