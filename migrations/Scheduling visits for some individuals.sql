set role ctrith_iph;

-- Ticket link - https://avni.freshdesk.com/a/tickets/3053

-- The visits didn't get scheduled the first time because the consent to collect blood samples was selected as "No", and then later on, it was edited to "Yes".
-- But because of the edit scenario logic, the visits didn't get scheduled. Hence scheduling from backend via script.

-- Below mentioned are the id's of the individual for whom the visits need to be scheduled
-- 1358626, 1364018, 1345438, 1406640

select * from encounter_type et where name = 'Collect blood sample details' ; -- 2151

select * from encounter_type et where name = 'Record blood sample result' ; -- 2155

-- Scheduling First blood sample result.

with to_be_scheduled as (
	select 
	id	ind_id,
	address_id add_id, 
	created_by_id cre_id
	from ctrith_iph.individual
	where id in (1358626, 1364018, 1345438, 1406640)
)
insert into encounter (
observations, encounter_date_time, encounter_type_id, individual_id, uuid,
"version", organisation_id, is_voided, audit_id, earliest_visit_date_time,
max_visit_date_time, cancel_date_time, cancel_observations, "name", created_by_id,
last_modified_by_id, created_date_time, last_modified_date_time, address_id)
select '{}'::jsonb, null, 2155, ind_id, uuid_generate_v4(),
0, 323, false, create_audit(), now(),
now()::timestamp + '3 days', null, '{}'::jsonb, 'Record baseline blood sample result 1', cre_id,
cre_id, now(), now(), add_id
from to_be_scheduled;


-- Scheduling 1st year blood sample details

with to_be_scheduled as (
	select 
	id	ind_id,
	address_id add_id, 
	created_by_id cre_id
	from ctrith_iph.individual
	where id in (1358626, 1364018, 1345438, 1406640)
)
insert into encounter (
observations, encounter_date_time, encounter_type_id, individual_id, uuid,
"version", organisation_id, is_voided, audit_id, earliest_visit_date_time,
max_visit_date_time, cancel_date_time, cancel_observations, "name", created_by_id,
last_modified_by_id, created_date_time, last_modified_date_time, address_id)
select '{}'::jsonb, null, 2151, ind_id, uuid_generate_v4(),
0, 323, false, create_audit(), now()::timestamp + '11 months',
now()::timestamp + '11 months 3days', null, '{}'::jsonb, 'Collect 1st year blood sample', cre_id,
cre_id, now(), now(), add_id
from to_be_scheduled;
