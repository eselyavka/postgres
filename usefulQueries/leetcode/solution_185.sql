-- leetcode.com #185
/*
Employee
+----+-------+--------+--------------+
| Id | Name  | Salary | DepartmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 70000  | 1            |
| 2  | Henry | 80000  | 2            |
| 3  | Sam   | 60000  | 2            |
| 4  | Max   | 90000  | 1            |
| 5  | Janet | 69000  | 1            |
| 6  | Randy | 85000  | 1            |
+----+-------+--------+--------------+

Department
+----+----------+
| Id | Name     |
+----+----------+
| 1  | IT       |
| 2  | Sales    |
+----+----------+
*/

WITH solution AS
  (WITH ranked_employee AS
     (SELECT d.name AS dep,
             e.name,
             e.salary
      FROM employee e,
           dep d
      WHERE e.dip = d.id
      ORDER BY d.name,
               e.salary DESC) SELECT dep,
                                     name,
                                     salary,
                                     rank() over (PARTITION BY dep
                                                  ORDER BY salary DESC)
   FROM ranked_employee)
SELECT dep,
       name,
       salary
FROM solution
WHERE rank BETWEEN 1 AND 3;
