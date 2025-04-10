/*- A cumulative query to generate `device_activity_datelist` from `events` */
insert into USER_DEVICES_CUMULATED
with deduped as (
	select 
		e.user_id,
		e.event_time,
		d.device_id,
		d.browser_type,
		d.device_type,
		d.os_type,
		row_number() over (partition by d.device_id, e.user_id,e.event_time) as row_num
	from devices d
			join events e on d.device_id = e.device_id
	where e.user_id is not null
)
, yesterday as (
	select 
		* 
	from user_devices_cumulated
	where event_date = '2022-12-31'
),today as (
	select 
		user_id,
		browser_type,
		DATE(cast(event_time as timestamp)) as date_active
	from deduped
	where DATE(cast(event_time as timestamp)) = DATE('2023-01-01')
		and user_id is not null and	row_num = 1
	group by user_id,
		browser_type,
		DATE(cast(event_time as timestamp)) 
)

select 
	coalesce (T.user_id, Y.user_id) as user_id,
	coalesce (T.browser_type, Y.browser_type) as browser_type,
	case 
		when y.device_activity_datelist is null then ARRAY[t.date_active] 
		when t.date_active is null then y.device_activity_datelist
		else ARRAY[t.date_active] || y.device_activity_datelist
	end as device_activity_datelist,
	coalesce(t.date_active, y.EVENT_DATE + interval '1 day') as EVENT_DATE
from today t 
	full outer join yesterday y 
	on t.user_id = y.user_id
	and T.browser_type = Y.browser_type;
