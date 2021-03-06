-- leetcode.com #177
/*

Employee
+----+--------+
| Id | Salary |
+----+--------+
| 1  | 100    |
| 2  | 200    |
| 3  | 300    |
+----+--------+

+------------------------+
| getNthHighestSalary(2) |
+------------------------+
| 200                    |
+------------------------+
*/

CREATE OR REPLACE FUNCTION getNthHighestSalary(N INT) RETURNS INT
AS $$ SELECT salary FROM (SELECT id,salary,rank() OVER (ORDER BY salary DESC) FROM employee) AS t WHERE rank > N-1 LIMIT 1; $$
LANGUAGE SQL
STABLE
RETURNS NULL ON NULL INPUT;
