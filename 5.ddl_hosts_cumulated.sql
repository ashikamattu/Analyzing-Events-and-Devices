/*
- A DDL for `hosts_cumulated` table 
- a `host_activity_datelist` column which logs to see which dates each host is experiencing any activity
*/
create table HOSTS_CUMULATED (
	HOST text,
	CURR_DATE DATE,
	host_activity_datelist DATE[],
	primary key (HOST, CURR_DATE)
)