/*
- A monthly, reduced fact table DDL `host_activity_reduced`
- month
- host
- hit_array
- unique_visitors array 
*/
create table host_activity_reduced(
	MONTH DATE,
	HOST text,
	HIT_ARRAY real[],
	UNIQUE_VISITORS real[],	
	primary key (HOST, MONTH)
)
