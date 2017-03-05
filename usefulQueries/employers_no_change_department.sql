/*
CREATE TABLE employee (
    employee_id bigint,
    department_id smallint,
    salary integer,
    ts timestamp without time zone
);
*/

WITH res
     AS (WITH employers_distinct_dep
              AS (SELECT employee_id,
                         array_agg(department_id) AS deps
                  FROM   employee
                  GROUP  BY employee_id)
         SELECT employee_id,
                (SELECT array_agg(d) AS da
                 FROM   (SELECT DISTINCT d
                         FROM   unnest(deps) d) t)
          FROM   employers_distinct_dep)
SELECT max(salary)
FROM   employee
WHERE  employee_id IN (SELECT res.employee_id
                       FROM   res
                       WHERE  array_length(res.da, 1) = 1);
