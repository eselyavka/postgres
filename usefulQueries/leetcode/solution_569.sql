-- leetcode.com #569

/*
Employee
+-----+------------+--------+
|Id   | Company    | Salary |
+-----+------------+--------+
|1    | A          | 2341   |
|2    | A          | 341    |
|3    | A          | 15     |
|4    | A          | 15314  |
|5    | A          | 451    |
|6    | A          | 513    |
|7    | B          | 15     |
|8    | B          | 13     |
|9    | B          | 1154   |
|10   | B          | 1345   |
|11   | B          | 1221   |
|12   | B          | 234    |
|13   | C          | 2345   |
|14   | C          | 2645   |
|15   | C          | 2645   |
|16   | C          | 2652   |
|17   | C          | 65     |
+-----+------------+--------+

Output
+-----+------------+--------+
|Id   | Company    | Salary |
+-----+------------+--------+
|5    | A          | 451    |
|6    | A          | 513    |
|12   | B          | 234    |
|9    | B          | 1154   |
|14   | C          | 2645   |
+-----+------------+--------+
*/

WITH cte AS
  (SELECT id,
          company,
          salary,
          -1 + row_number() over(PARTITION BY company
                                 ORDER BY company,salary) AS row_number
   FROM employee)
SELECT t1.id,
       t1.company,
       t1.salary
FROM cte t1
JOIN
  (SELECT company,
          count(*) AS num
   FROM employee
   GROUP BY company) t2 ON t1.company = t2.company
AND (t1.row_number = t2.num/2
     OR t1.row_number = (t2.num - 1)/2);
