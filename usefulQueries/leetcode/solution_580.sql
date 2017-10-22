-- leetcode.com #580

/*
student
| student_id | student_name | gender | dept_id |
|------------|--------------|--------|---------|
| 1          | Jack         | M      | 1       |
| 2          | Jane         | F      | 1       |
| 3          | Mark         | M      | 2       |

department
| dept_id | dept_name   |
|---------|-------------|
| 1       | Engineering |
| 2       | Science     |
| 3       | Law         |

Output
| dept_name   | student_number |
|-------------|----------------|
| Engineering | 2              |
| Science     | 1              |
| Law         | 0              |
*/

SELECT dept_name,
       sum(cnt) AS student_number
FROM
  (SELECT CASE
              WHEN student_id IS NULL THEN 0
              ELSE 1
          END AS cnt,
          dept_name
   FROM
     (SELECT student_id,
             dept_name
      FROM student s
      RIGHT JOIN department d ON s.dept_id=d.dept_id) t) res
GROUP BY dept_name
ORDER BY student_number DESC,
         dept_name;
