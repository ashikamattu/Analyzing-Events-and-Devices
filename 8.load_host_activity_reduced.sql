/*
An incremental query that loads `host_activity_reduced` on a daily interval
*/
insert into host_activity_reduced
with DAILY_AGG as (
select 
	count(distinct user_id) as num_unique_visitors,
	host,
	count(1) as host_hitS,
	DATE(event_time) as event_date
from events 
where DATE(event_time) = '2023-01-01' and user_id is not null 
group by host, DATE(event_time)
), YESTERDAY as (
	select 
		*
	from host_activity_reduced 
	where MONTH = DATE('2023-01-01')
)

select
	coalesce (YA.MONTH, date_trunc('MONTH', DA.EVENT_DATE)) as month,
	coalesce (YA.HOST, DA.HOST) as HOST,
	
	case when YA.HIT_ARRAY is not null 
		then YA.HIT_ARRAY || ARRAY[cast(coalesce(DA.HOST_HITS, 0) as real)]
	when YA.HIT_ARRAY is null then
		ARRAY_FILL(0, array[coalesce(EVENT_DATE - DATE(date_trunc('MONTH', EVENT_DATE)), 0)])
		|| ARRAY[cast(coalesce(DA.HOST_HITS, 0) as INTEGER)]
	end as HIT_ARRAY,
	
	case when YA.UNIQUE_VISITORS is not null 
		then YA.UNIQUE_VISITORS || ARRAY[cast(coalesce(DA.num_unique_visitors, 0) as real)]
	when YA.UNIQUE_VISITORS is null then
		ARRAY_FILL(0, array[coalesce(EVENT_DATE - DATE(date_trunc('MONTH', EVENT_DATE)), 0)])
		|| ARRAY[cast(coalesce(DA.num_unique_visitors, 0) as INTEGER)]
	end as UNIQUE_VISITORS
	
from DAILY_AGG DA FULL outer JOIN 
	YESTERDAY YA ON DA.host = YA.host
ON CONFLICT (host, month)
DO 
    UPDATE SET HIT_ARRAY = EXCLUDED.HIT_ARRAY,
				UNIQUE_VISITORS = EXCLUDED.UNIQUE_VISITORS;

