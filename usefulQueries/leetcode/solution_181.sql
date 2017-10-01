-- leetcode.com #181
/*

Employee
+----+-------+--------+-----------+
| Id | Name  | Salary | ManagerId |
+----+-------+--------+-----------+
| 1  | Joe   | 70000  | 3         |
| 2  | Henry | 80000  | 4         |
| 3  | Sam   | 60000  | NULL      |
| 4  | Max   | 90000  | NULL      |
+----+-------+--------+-----------+

+----------+
| Employee |
+----------+
| Joe      |
+----------+
*/

SELECT e.name
FROM employee e
JOIN employee em ON e.managerid=em.id
WHERE e.salary-em.salary > 0;
