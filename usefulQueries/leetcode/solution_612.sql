-- leetcode.com #617

/*
point_2d
| x  | y  |
|----|----|
| -1 | -1 |
| 0  | 0  |
| -1 | -2 |

| shortest |
|----------|
| 1.00     |
*/

SELECT cast(sqrt(min(pow(p1.x-p2.x,2)+pow(p1.y-p2.y,2))) AS NUMERIC(5,2)) AS shortest
FROM point_2d p1,
     point_2d p2
WHERE p1.x <> p2.x
  OR p1.y <> p2.y;
