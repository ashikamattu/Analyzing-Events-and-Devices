/*- A DDL for an `user_devices_cumulated` table that has:
  - a `device_activity_datelist` which tracks a users active days by `browser_type`
    - a `browser_type` column with multiple rows for each user 
*/
create table user_devices_cumulated (
	user_id numeric,
	browser_type TEXT,
	device_activity_datelist DATE[],
	event_date DATE,
	primary key (user_id, browser_type, event_date)
);