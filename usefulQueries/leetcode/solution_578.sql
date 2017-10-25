-- leetcode.com #578

/*
survey_log
+------+-----------+--------------+------------+-----------+------------+
| uid  | action    | question_id  | answer_id  | q_num     | timestamp  |
+------+-----------+--------------+------------+-----------+------------+
| 5    | show      | 285          | null       | 1         | 123        |
| 5    | answer    | 285          | 124124     | 1         | 124        |
| 5    | show      | 369          | null       | 2         | 125        |
| 5    | skip      | 369          | null       | 2         | 126        |
+------+-----------+--------------+------------+-----------+------------+

Output:
+-------------+
| survey_log  |
+-------------+
|    285      |
+-------------+
*/

SELECT question_id AS survey_log
FROM
  (SELECT question_id,
          answer_id,
          count(*) AS cnt
   FROM survey_log
   WHERE answer_id IS NOT NULL
   GROUP BY question_id,
            answer_id
   ORDER BY cnt DESC
   LIMIT 1) t;
