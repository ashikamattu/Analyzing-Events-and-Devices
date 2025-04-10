/*
The incremental query to generate `host_activity_datelist`
*/
insert into HOSTS_CUMULATED
with YESTERDAY as (
	select
	 * 
	from HOSTS_CUMULATED where 
	CURR_DATE = '2022-12-31'
), TODAY AS (
	select 
		HOST,
		DATE(EVENT_TIME) as EVENT_DATE
	from events e 
	where USER_ID is not null 
	and DATE(EVENT_TIME) = '2023-01-01'
	group by HOST, DATE(EVENT_TIME)
)

select 
	coalesce(T.HOST, Y.HOST) as HOST,
	coalesce(T.EVENT_DATE, Y.CURR_DATE + interval '1 DAY') as CURR_DATE,
	case 
		when Y.host_activity_datelist is null then ARRAY[T.EVENT_DATE]
		when T.EVENT_DATE is null then Y.host_activity_datelist
		else ARRAY[T.EVENT_DATE] || Y.host_activity_datelist
	end as host_activity_datelist
from TODAY as T
full outer join YESTERDAY Y 
on Y.HOST = T.HOST
