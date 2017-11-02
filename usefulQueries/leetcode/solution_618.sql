-- leetcode.com #618

/*
student
| name   | continent |
|--------|-----------|
| Jack   | America   |
| Pascal | Europe    |
| Xi     | Asia      |
| Jane   | America   |

Output:
| America | Asia | Europe |
|---------|------|--------|
| Jack    | Xi   | Pascal |
| Jane    |      |        |
*/

SELECT t1.name AS "America",
       t2.name AS "Asia",
       t3.name AS "Europe"
FROM
  (SELECT name,
          row_number() OVER ()
   FROM student
   WHERE continent = 'America'
   ORDER BY 1) t1
LEFT JOIN
  (SELECT name,
          row_number() OVER ()
   FROM student
   WHERE continent = 'Asia'
   ORDER BY 1) t2 ON t1.row_number = t2.row_number
LEFT JOIN
  (SELECT name,
          row_number() OVER ()
   FROM student
   WHERE continent = 'Europe'
   ORDER BY 1) t3 ON t1.row_number = t3.row_number;
