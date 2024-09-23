-- FUNCTION: public.generate_test_departments()

-- DROP FUNCTION IF EXISTS public.generate_test_departments();

CREATE OR REPLACE FUNCTION public.generate_test_departments(
	)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

BEGIN

INSERT INTO client_groups (client_group_name) 
SELECT 'A1 Emergency Physicians' 
	WHERE NOT EXISTS (SELECT NULL FROM client_groups WHERE client_group_name = 'A1 Emergency Physicians')
UNION
SELECT 'Plains Emergency Physicians' 
	WHERE NOT EXISTS (SELECT NULL FROM client_groups WHERE client_group_name = 'Plains Emergency Physicians')
UNION
SELECT 'Valley Emergency Physicians' 
	WHERE NOT EXISTS (SELECT NULL FROM client_groups WHERE client_group_name = 'Valley Emergency Physicians');

INSERT INTO facilities (facility_name, client_group_id)
select 'Memorial Hospital' as facility_name, z.id as client_group_id
from client_groups as z where z.client_group_name = 'A1 Emergency Physicians'
AND NOT EXISTS (
	SELECT NULL FROM client_groups AS cg
	INNER JOIN facilities as f on f.client_group_id = cg.id
	WHERE cg.client_group_name = 'A1 Emergency Physicians' 
	AND f.facility_name = 'Memorial Hospital');

INSERT INTO facilities (facility_name, client_group_id)
select 'Regional Hospital' as facility_name, z.id as client_group_id
from client_groups as z where z.client_group_name = 'A1 Emergency Physicians'
AND NOT EXISTS (
	SELECT NULL FROM client_groups AS cg
	INNER JOIN facilities as f on f.client_group_id = cg.id
	WHERE cg.client_group_name = 'A1 Emergency Physicians' 
	AND f.facility_name = 'Regional Hospital');

INSERT INTO facilities (facility_name, client_group_id)
select 'Plains Memorial Hospital' as facility_name, z.id as client_group_id
from client_groups as z where z.client_group_name = 'Plains Emergency Physicians'
AND NOT EXISTS (
	SELECT NULL FROM client_groups AS cg
	INNER JOIN facilities as f on f.client_group_id = cg.id
	WHERE cg.client_group_name = 'Plains Emergency Physicians' 
	AND f.facility_name = 'Plains Memorial Hospital');

INSERT INTO facilities (facility_name, client_group_id)
select 'Plains Regional Hospital' as facility_name, z.id as client_group_id
from client_groups as z where z.client_group_name = 'Plains Emergency Physicians'
AND NOT EXISTS (
	SELECT NULL FROM client_groups AS cg
	INNER JOIN facilities as f on f.client_group_id = cg.id
	WHERE cg.client_group_name = 'Plains Emergency Physicians' 
	AND f.facility_name = 'Plains Regional Hospital');

INSERT INTO facilities (facility_name, client_group_id)
select 'Upper Valley Memorial Hospital' as facility_name, z.id as client_group_id
from client_groups as z where z.client_group_name = 'Valley Emergency Physicians'
AND NOT EXISTS (
	SELECT NULL FROM client_groups AS cg
	INNER JOIN facilities as f on f.client_group_id = cg.id
	WHERE cg.client_group_name = 'Valley Emergency Physicians' 
	AND f.facility_name = 'Upper Valley Memorial Hospital');

INSERT INTO facilities (facility_name, client_group_id)
select 'MidVale Regional Hospital' as facility_name, z.id as client_group_id
from client_groups as z where z.client_group_name = 'Valley Emergency Physicians'
AND NOT EXISTS (
	SELECT NULL FROM client_groups AS cg
	INNER JOIN facilities as f on f.client_group_id = cg.id
	WHERE cg.client_group_name = 'Valley Emergency Physicians' 
	AND f.facility_name = 'MidVale Regional Hospital');

INSERT INTO facilities (facility_name, client_group_id)
select 'Lower Valley Memorial Hospital' as facility_name, z.id as client_group_id
from client_groups as z where z.client_group_name = 'Valley Emergency Physicians'
AND NOT EXISTS (
	SELECT NULL FROM client_groups AS cg
	INNER JOIN facilities as f on f.client_group_id = cg.id
	WHERE cg.client_group_name = 'Valley Emergency Physicians' 
	AND f.facility_name = 'Lower Valley Memorial Hospital');

INSERT INTO departments (department_name, facility_id)
select 'Main ED' as department_name, f.id as facility_id
from facilities as f
WHERE NOT EXISTS (
	SELECT NULL FROM departments AS d WHERE d.department_name = 'Main ED' AND d.facility_id = f.id
);

INSERT INTO departments (department_name, facility_id)
select 'Fast Track' as department_name, f.id as facility_id
from facilities as f
WHERE NOT EXISTS (
	SELECT NULL FROM departments AS d WHERE d.department_name = 'Fast Track' AND d.facility_id = f.id
);

INSERT INTO users (username) 
SELECT 'max_patton@yahoo.com'
WHERE NOT EXISTS (
	SELECT NULL FROM users AS u WHERE u.username = 'max_patton@yahoo.com'
);

INSERT INTO user_department_auth (user_id, department_id, status) 
SELECT u.id, d.id, 'ACTIVE'
FROM users as u
CROSS JOIN departments as d 
WHERE NOT EXISTS (
	SELECT NULL FROM user_department_auth AS uda WHERE uda.user_id = u.id AND uda.department_id = d.id
);

INSERT INTO department_configuration (provider_type, hourly_cost, peak_capacity, department_id)
SELECT 'PHYS', 200.0, 12.5, d.id
FROM departments AS d
WHERE NOT EXISTS (
	SELECT NULL FROM department_configuration AS dc WHERE dc.provider_type = 'PHYS' AND dc.department_id = d.id
);

INSERT INTO department_configuration (provider_type, hourly_cost, peak_capacity, department_id)
SELECT 'APP', 80.0, 8.0, d.id
FROM departments AS d
WHERE NOT EXISTS (
	SELECT NULL FROM department_configuration AS dc WHERE dc.provider_type = 'APP' AND dc.department_id = d.id
);

END;

$BODY$;

ALTER FUNCTION public.generate_test_departments()
    OWNER TO robertpatton;
