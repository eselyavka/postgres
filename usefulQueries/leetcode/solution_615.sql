-- leetcode.com #615

/*
salary
| id | employee_id | amount | pay_date   |
|----|-------------|--------|------------|
| 1  | 1           | 9000   | 2017-03-31 |
| 2  | 2           | 6000   | 2017-03-31 |
| 3  | 3           | 10000  | 2017-03-31 |
| 4  | 1           | 7000   | 2017-02-28 |
| 5  | 2           | 6000   | 2017-02-28 |
| 6  | 3           | 8000   | 2017-02-28 |

employee
| employee_id | department_id |
|-------------|---------------|
| 1           | 1             |
| 2           | 2             |
| 3           | 2             |

output
| pay_month | department_id | comparison  |
|-----------|---------------|-------------|
| 2017-03   | 1             | higher      |
| 2017-03   | 2             | lower       |
| 2017-02   | 1             | same        |
| 2017-02   | 2             | same        |
*/

SELECT t1.pay_month,
       t1.department_id,
       CASE
           WHEN t1.avg > t2.avg THEN 'higher'
           WHEN t1.avg < t2.avg THEN 'lower'
           ELSE 'same'
       END AS comparions
FROM
  (SELECT pay_month,
          department_id,
          avg(amount) AS AVG
   FROM
     (SELECT e.employee_id,
             e.department_id,
             s.amount,
             to_char(s.pay_date, 'YYYY-MM') AS pay_month
      FROM salary s,
           employee e
      WHERE s.employee_id = e.employee_id
      ORDER BY id) t
   GROUP BY department_id,
            pay_month) t1,

  (SELECT to_char(pay_date, 'YYYY-MM') AS pay_month,
          avg(amount) AS AVG
   FROM salary
   GROUP BY 1) t2
WHERE t1.pay_month=t2.pay_month
ORDER BY department_id,
         pay_month;
