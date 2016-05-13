SELECT dep_name,
       emp_name,
       salary
FROM
  (SELECT d.name AS dep_name,
          e.name AS emp_name,
          e.salary,
          rank() OVER (PARTITION BY e.depid
                       ORDER BY e.salary DESC)
   FROM department d
   JOIN employee e ON d.id=e.depid) AS t
WHERE rank <=3;
