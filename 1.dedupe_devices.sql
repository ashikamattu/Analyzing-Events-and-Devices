/*A query to deduplicate `devices` so there's no duplicates*/
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
SELECT * FROM DEDUPED WHERE ROW_NUM = 1