-- leetcode.com #262
/*
Trips
+----+-----------+-----------+---------+--------------------+----------+
| Id | Client_Id | Driver_Id | City_Id |        Status      |Request_at|
+----+-----------+-----------+---------+--------------------+----------+
| 1  |     1     |    10     |    1    |     completed      |2013-10-01|
| 2  |     2     |    11     |    1    | cancelled_by_driver|2013-10-01|
| 3  |     3     |    12     |    6    |     completed      |2013-10-01|
| 4  |     4     |    13     |    6    | cancelled_by_client|2013-10-01|
| 5  |     1     |    10     |    1    |     completed      |2013-10-02|
| 6  |     2     |    11     |    6    |     completed      |2013-10-02|
| 7  |     3     |    12     |    6    |     completed      |2013-10-02|
| 8  |     2     |    12     |    12   |     completed      |2013-10-03|
| 9  |     3     |    10     |    12   |     completed      |2013-10-03|
| 10 |     4     |    13     |    12   | cancelled_by_driver|2013-10-03|
+----+-----------+-----------+---------+--------------------+----------+

Users
+----------+--------+--------+
| Users_Id | Banned |  Role  |
+----------+--------+--------+
|    1     |   No   | client |
|    2     |   Yes  | client |
|    3     |   No   | client |
|    4     |   No   | client |
|    10    |   No   | driver |
|    11    |   No   | driver |
|    12    |   No   | driver |
|    13    |   No   | driver |
+----------+--------+--------+
*/

with solution as 
(
   with cancellation_rate as 
   (
      with unbanned as 
      (
         select
            t.request_at 
         from
            trips t,
            users u 
         where
            t.client_id = u.users_id 
            and u.banned = 'no' 
         order by
            t.request_at desc 
      )
      select
         request_at,
         count(*) as cnt_unbanned 
      from
         unbanned 
      group by
         request_at 
   )
   select
      cancellation_rate.request_at as d,
      cnt_cancelled::float / cnt_unbanned::float as cr 
   from
      cancellation_rate 
      left join
         (
            select
               request_at,
               count(*) as cnt_cancelled 
            from
               (
                  select
                     t.request_at 
                  from
                     trips t,
                     users u 
                  where
                     t.client_id = u.users_id 
                     and u.banned = 'no' 
                     and status in 
                     (
                        'cancelled_by_driver',
                        'cancelled_by_client' 
                     )
                  order by
                     t.request_at desc 
               )
               as t 
            group by
               request_at 
         )
         as t2 
         on cancellation_rate.request_at = t2.request_at
)
select
   d as Day,
   CASE
      when
         cr is null 
      then
         0.0
      ELSE
         cr
   END::numeric(5,2)
   as Cancellation_Rate 
from
   solution 
order by
   Day;
