-- cheduling the ‘Mental Health and Social Support’ visit for the 12-month and 24-month
-- If the latest visit is 6 month then schedule it for 12 month
-- If the latest visit is 12 month then schedule it for 24 month there are only some case

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET ROLE ctrith_iph;

SELECT * FROM organisation o WHERE o."name" = 'CTRITH IPH'; -- 323

select * FROM encounter_type et WHERE et.name = 'Mental health and social support' ; -- 2680

SELECT * FROM users u WHERE u.username ILIKE '%adam@ctrith_iph%'; --14106

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN TRANSACTION;

SET ROLE ctrith_iph;

-- Select Query
WITH mental_health_latest AS (
	SELECT
		pe.encounter_type_id,
		pe.program_enrolment_id,
		pe2.individual_id,
		pe."name",
		pe.earliest_visit_date_time,
		pe.encounter_date_time,
		i.address_id,
		i.organisation_id,
		row_number() OVER (PARTITION BY pe.program_enrolment_id ORDER BY pe.earliest_visit_date_time DESC ) AS latest_encounter
	FROM
		program_encounter pe
	JOIN program_enrolment pe2 ON
		pe2.id = pe.program_enrolment_id
		AND pe2.program_exit_date_time IS NULL
	JOIN "program" p ON 
		p.id = pe2.program_id
		AND p."name" = 'Mother'
	JOIN individual i ON 
		i.id = pe2.individual_id
		AND i.is_voided IS FALSE
	WHERE
		pe.encounter_type_id = 2680
)
SELECT 
	mh.encounter_type_id,
	mh.program_enrolment_id,
	mh.individual_id,
	mh.address_id,
	mh.organisation_id,
	CASE
		WHEN mh."name" = 'Record 6th month mental health and social support details' THEN '12 Month Women Follow-up form'
		WHEN mh."name" = 'Record 12th month mother mental health and social support details' THEN '24 Month Women Follow-up form'
	END AS name,
	CASE
		WHEN mh."name" = 'Record 6th month mental health and social support details' THEN mh.earliest_visit_date_time::timestamp + '6 months'
		WHEN mh."name" = 'Record 12th month mother mental health and social support details' THEN mh.earliest_visit_date_time::timestamp + '1 year'
	END AS earliest_visit_date_time
FROM
	mental_health_latest AS mh
WHERE 
	mh.latest_encounter = 1
	AND mh.encounter_date_time IS NOT NULL 
	AND mh."name" IN (
	  'Record 6th month mental health and social support details',
	  'Record 12th month mother mental health and social support details'
	)


-- Insert Query
WITH mental_health_latest AS (
	SELECT
		pe.encounter_type_id,
		pe.program_enrolment_id,
		pe2.individual_id,
		pe."name",
		pe.earliest_visit_date_time,
		pe.encounter_date_time,
		i.address_id,
		i.organisation_id,
		row_number() OVER (PARTITION BY pe.program_enrolment_id ORDER BY pe.earliest_visit_date_time DESC ) AS latest_encounter
	FROM
		program_encounter pe
	JOIN program_enrolment pe2 ON
		pe2.id = pe.program_enrolment_id
		AND pe2.program_exit_date_time IS NULL
	JOIN "program" p ON 
		p.id = pe2.program_id
		AND p."name" = 'Mother'
	JOIN individual i ON 
		i.id = pe2.individual_id
		AND i.is_voided IS FALSE
	WHERE
		pe.encounter_type_id = 2680
),
to_be_scheduled AS (
	SELECT 
		mh.encounter_type_id,
		mh.program_enrolment_id,
		mh.individual_id,
		mh.address_id,
		mh.organisation_id,
		CASE
			WHEN mh."name" = 'Record 6th month mental health and social support details' THEN '12 Month Women Follow-up form'
			WHEN mh."name" = 'Record 12th month mother mental health and social support details' THEN '24 Month Women Follow-up form'
		END AS name,
		CASE
			WHEN mh."name" = 'Record 6th month mental health and social support details' THEN mh.earliest_visit_date_time::timestamp + '6 months'
			WHEN mh."name" = 'Record 12th month mother mental health and social support details' THEN mh.earliest_visit_date_time::timestamp + '1 year'
		END AS earliest_visit_date_time
	FROM
		mental_health_latest AS mh
	WHERE 
		mh.latest_encounter = 1
		AND mh.encounter_date_time IS NOT NULL 
		AND mh."name" IN (
		  'Record 6th month mental health and social support details',
		  'Record 12th month mother mental health and social support details'
		)
)
INSERT INTO program_encounter (
	observations,
	earliest_visit_date_time,
	encounter_date_time,
	program_enrolment_id,
	"uuid",
	"version",
	encounter_type_id,
	"name",
	max_visit_date_time,
	organisation_id,
	cancel_date_time,
	cancel_observations,
	is_voided,
	created_by_id,
	last_modified_by_id,
	created_date_time,
	last_modified_date_time,
	address_id,
	individual_id,
	filled_by_id
)
SELECT
	'{}'::jsonb,
	earliest_visit_date_time,
	NULL,
	program_enrolment_id,
	uuid_generate_v4(),
	0,
	encounter_type_id,
	"name",
	earliest_visit_date_time + '15 days',
	organisation_id,
	NULL,
	'{}'::jsonb,
	FALSE,
	14106,
	14106,
	current_timestamp + (random() * 5000 * (interval '1 millisecond')),
	current_timestamp + (random() * 5000 * (interval '1 millisecond')),
	address_id,
	individual_id,
	14106
FROM 
	to_be_scheduled


ROLLBACK;
--COMMIT;
