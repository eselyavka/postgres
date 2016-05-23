SELECT e.name
FROM employee e
JOIN employee em ON e.managerid=em.id
WHERE e.salary-em.salary > 0;
