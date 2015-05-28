SELECT field
 ,count(*) AS name_count
 ,sum(count(*)) OVER () AS total_count
 ,100 * (count(*) / sum(count(*)) OVER ())
FROM table_name
GROUP BY field
ORDER BY count(*) DESC;

--Example pipe with 10 major goods and other
WITH RECURSIVE allGoods (
 goods_name
 ,PERCENT
 )
AS (
 SELECT NAME
  ,100 * (count(*) / sum(count(*)) OVER ())
 FROM goodsTable
 GROUP BY NAME
 ORDER BY count(*) DESC
 )
 ,tenMainGoods (
 goods_name
 ,PERCENT
 )
AS (
 SELECT *
 FROM allGoods limit 10
 )
 ,othergoods (
 goods_name
 ,PERCENT
 )
AS (
 SELECT *
 FROM allGoods
 
 EXCEPT
 
 SELECT *
 FROM tenMainGoods
 )
 ,finalPipe (
 goods_name
 ,PERCENT
 )
AS (
 SELECT *
 FROM tenMainGoods
 
 UNION ALL
 
 SELECT 'other'
  ,sum(PERCENT)
 FROM othergoods
 )
SELECT *
FROM finalPipe
