SELECT field
 ,count(*) AS name_count
 ,sum(count(*)) OVER () AS total_count
 ,100 * (count(*) / sum(count(*)) OVER ())
FROM table_name
GROUP BY field
ORDER BY count(*) DESC;
