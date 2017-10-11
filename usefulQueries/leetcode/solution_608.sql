-- leetcode.com #608

/*
tree
+----+------+
| id | p_id |
+----+------+
| 1  | null |
| 2  | 1    |
| 3  | 1    |
| 4  | 2    |
| 5  | 2    |
+----+------+

+----+------+
| id | Type |
+----+------+
| 1  | Root |
| 2  | Inner|
| 3  | Leaf |
| 4  | Leaf |
| 5  | Leaf |
+----+------+
*/

SELECT Id,
       CASE
           WHEN p_id IS NULL THEN 'Root'
           WHEN EXISTS
                  (SELECT 1
                   FROM tree tt
                   WHERE tt.p_id=t1.id) THEN 'Inner'
           ELSE 'Leaf'
       END AS TYPE
FROM tree t1
ORDER BY id;
