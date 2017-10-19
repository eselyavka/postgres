-- leetcode.com #585

/*
insurance
| PID | TIV_2015 | TIV_2016 | LAT | LON |
|-----|----------|----------|-----|-----|
| 1   | 10       | 5        | 10  | 10  |
| 2   | 20       | 20       | 20  | 20  |
| 3   | 10       | 30       | 20  | 20  |
| 4   | 10       | 40       | 40  | 40  |

| TIV_2016 |
|----------|
| 45.00    |
*/

SELECT sum(tiv_2016) AS TIV_2016
FROM insurance
WHERE pid IN
    (SELECT t1.pid
     FROM
       (SELECT pid
        FROM insurance
        WHERE tiv_2015 IN
            (SELECT tiv_2015
             FROM
               (SELECT tiv_2015,
                       count(*)
                FROM insurance
                GROUP BY tiv_2015
                HAVING count(*) > 1) t)) t1
     LEFT JOIN
       (SELECT pid
        FROM insurance i,

          (SELECT lat,
                  lon,
                  count(*)
           FROM insurance
           GROUP BY lat,
                    lon
           HAVING count(*) > 1) t
        WHERE i.lat=t.lat
          AND i.lon = t.lon) t2 ON t1.pid = t2.pid
     WHERE t2.pid IS NULL);
