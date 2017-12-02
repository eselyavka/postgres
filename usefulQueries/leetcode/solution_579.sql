-- leetcode.com #579

/*
Employee
| Id | Month | Salary |
|----|-------|--------|
| 1  | 1     | 20     |
| 2  | 1     | 20     |
| 1  | 2     | 30     |
| 2  | 2     | 30     |
| 3  | 2     | 40     |
| 1  | 3     | 40     |
| 3  | 3     | 60     |
| 1  | 4     | 60     |
| 3  | 4     | 70     |

Output
| Id | Month | Salary |
|----|-------|--------|
| 1  | 3     | 90     |
| 1  | 2     | 50     |
| 1  | 1     | 20     |
| 2  | 1     | 20     |
| 3  | 3     | 100    |
| 3  | 2     | 40     |
*/

WITH res AS
  (SELECT t.id,
          e.month,
          salary AS salary
   FROM employee e
   JOIN
     (SELECT id,
             min(MONTH),
             max(MONTH) - 1 AS MAX
      FROM employee
      GROUP BY id) t ON e.id=t.id
   AND MONTH BETWEEN MIN AND MAX
   GROUP BY t.id,
            e.month,
            salary)
SELECT id,
       MONTH,
       sum(salary) OVER (PARTITION BY id
                         ORDER BY MONTH DESC ROWS BETWEEN CURRENT ROW AND 2 following) AS salary
FROM res
ORDER BY id ASC,
         MONTH DESC;
