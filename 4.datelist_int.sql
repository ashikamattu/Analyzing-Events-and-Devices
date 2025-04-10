/*
A `datelist_int` generation query. Converts the `device_activity_datelist` column into a `datelist_int` column.
*/
with users as (
	select 
	* 
	from user_devices_cumulated
	where event_date = DATE('2023-01-31')
), series as (
	select 
	* 
	from generate_series(DATE('2023-01-01'), DATE('2023-01-31'), interval '1 day') as series_date
), placeholder_ints as (
select
	case when device_activity_datelist @> array[DATE(series_date)]
		then pow(2, 32 - (event_date - DATE(series_date)))
		else 0 
	end as placeholder_int_val,
	* 
from users cross join series 
), bits as (
select 
	user_id,
	browser_type,
	cast(cast(sum(placeholder_int_val) as bigint) as bit(32)) as datelist_int
from placeholder_ints
group by user_id, browser_type)

select 
	user_id,
	browser_type,
	datelist_int,
	length(translate(cast(datelist_int as text),'0', '')) > 0 AS is_monthly_active,
	length(translate(cast(datelist_int as text),'0', '')) AS monthly_days_active,
	length(translate(cast(CAST(datelist_int AS BIT(32)) &
       CAST('11111110000000000000000000000000' AS BIT(32)) as text), '0', '')) > 0 as is_curr_week_active,
	length(translate(cast(CAST(datelist_int AS BIT(32)) &
       CAST('11111110000000000000000000000000' AS BIT(32)) as text), '0', '')) as curr_week_days_active,
	length(translate(cast(CAST(datelist_int AS BIT(32)) &
       CAST('00000001111111000000000000000000' AS BIT(32)) as text), '0', '')) > 0 as is_prev_week_active           
from bits
order by monthly_days_active desc; 

