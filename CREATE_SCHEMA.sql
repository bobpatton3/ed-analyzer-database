CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-------------------------------------------------------------

-- FUNCTION: public.set_uuid_field()

CREATE FUNCTION IF NOT EXISTS public.set_uuid_field()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
  -- Generate a new UUID using the uuid-ossp extension
  NEW.id := uuid_generate_v4();
  RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.set_uuid_field()
    OWNER TO robertpatton;

-------------------------------------------------------------

-- Table: public.client_groups

CREATE TABLE IF NOT EXISTS public.client_groups
(
    id uuid NOT NULL,
    client_group_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT client_groups_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.client_groups
    OWNER to robertpatton;


-------------------------------------------------------------

-- Table: public.facilities

CREATE TABLE IF NOT EXISTS public.facilities
(
    id uuid NOT NULL,
    facility_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    client_group_id uuid NOT NULL,
    CONSTRAINT facilities_pkey PRIMARY KEY (id),
    CONSTRAINT fk_facility_client_group FOREIGN KEY (client_group_id)
        REFERENCES public.client_groups (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.facilities
    OWNER to robertpatton;


-------------------------------------------------------------

-- Table: public.departments

CREATE TABLE IF NOT EXISTS public.departments
(
    id uuid NOT NULL,
    department_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    facility_id uuid NOT NULL,
    CONSTRAINT departments_pkey PRIMARY KEY (id),
    CONSTRAINT fk_department_facility FOREIGN KEY (facility_id)
        REFERENCES public.facilities (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.departments
    OWNER to robertpatton;


-------------------------------------------------------------


-- Table: public.department_configuration

CREATE TABLE IF NOT EXISTS public.department_configuration
(
    id uuid NOT NULL,
    provider_type character varying(31) COLLATE pg_catalog."default" NOT NULL,
    hourly_cost numeric(10,2) NOT NULL,
    peak_capacity numeric(10,1) NOT NULL,
    department_id uuid NOT NULL,
    CONSTRAINT fk_department_configuration_department FOREIGN KEY (department_id)
        REFERENCES public.departments (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.department_configuration
    OWNER to robertpatton;


-------------------------------------------------------------


-- Table: public.users

CREATE TABLE IF NOT EXISTS public.users
(
    id uuid NOT NULL,
    username character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Users_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.users
    OWNER to robertpatton;


-------------------------------------------------------------

-- Table: public.user_department_auth

CREATE TABLE IF NOT EXISTS public.user_department_auth
(
    user_id uuid NOT NULL,
    department_id uuid NOT NULL,
    status character varying(31) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT user_department_auth_pkey PRIMARY KEY (user_id, department_id),
    CONSTRAINT fk_auth_department FOREIGN KEY (department_id)
        REFERENCES public.departments (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT fk_auth_user FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_department_auth
    OWNER to robertpatton;


-------------------------------------------------------------

-- Table: public.schedules

CREATE TABLE IF NOT EXISTS public.schedules
(
    id uuid NOT NULL,
    creation_date date,
    update_date date,
    owner character varying(31) COLLATE pg_catalog."default" NOT NULL,
    schedule_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    department_id uuid NOT NULL,
    CONSTRAINT schedules_pkey PRIMARY KEY (id),
    CONSTRAINT fk_schedules_departments FOREIGN KEY (department_id)
        REFERENCES public.departments (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.schedules
    OWNER to robertpatton;


-------------------------------------------------------------

-- Table: public.shifts

CREATE TABLE IF NOT EXISTS public.shifts
(
    id uuid NOT NULL,
    schedule_id uuid NOT NULL,
    start_hour integer NOT NULL,
    duration integer NOT NULL,
    provider_type character varying(10) COLLATE pg_catalog."default" NOT NULL,
    days_of_week boolean[] NOT NULL,
    CONSTRAINT shifts_pkey PRIMARY KEY (id),
    CONSTRAINT fk_shifts_schedules FOREIGN KEY (schedule_id)
        REFERENCES public.schedules (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.shifts
    OWNER to robertpatton;


-------------------------------------------------------------

-- Table: public.arrivals

CREATE TABLE IF NOT EXISTS public.arrivals
(
    arrival_datetime timestamp without time zone,
    rvus numeric(6,2),
    cpt character varying(100) COLLATE pg_catalog."default",
    age integer,
    id uuid NOT NULL,
    department_id uuid NOT NULL,
    CONSTRAINT arrivals_pkey PRIMARY KEY (id),
    CONSTRAINT fk_arrivals_department FOREIGN KEY (department_id)
        REFERENCES public.departments (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.arrivals
    OWNER to robertpatton;

-- Trigger: set_uuid_trigger

-- DROP TRIGGER IF EXISTS set_uuid_trigger ON public.arrivals;

CREATE TRIGGER set_uuid_trigger
    BEFORE INSERT
    ON public.arrivals
    FOR EACH ROW
    EXECUTE FUNCTION public.set_uuid_field();


-------------------------------------------------------------

-- View: public.department_metadata

CREATE OR REPLACE VIEW public.department_metadata
 AS
 WITH arrival_start_end AS (
         SELECT arrivals.department_id,
            min(arrivals.arrival_datetime) AS data_start_date,
            max(arrivals.arrival_datetime) AS data_end_date
           FROM arrivals
          GROUP BY arrivals.department_id
        ), phys_dm AS (
         SELECT cg.client_group_name,
            f.facility_name,
            d.department_name,
            dc.department_id,
            dc.hourly_cost AS phys_hourly_cost,
            dc.peak_capacity AS phys_peak_capacity,
            ase.data_start_date,
            ase.data_end_date
           FROM client_groups cg
             JOIN facilities f ON f.client_group_id = cg.id
             JOIN departments d ON d.facility_id = f.id
             JOIN department_configuration dc ON dc.department_id = d.id
             JOIN arrival_start_end ase ON ase.department_id = d.id
          WHERE dc.provider_type::text = 'PHYS'::text
        ), app_dm AS (
         SELECT dc.department_id,
            dc.hourly_cost AS app_hourly_cost,
            dc.peak_capacity AS app_peak_capacity
           FROM department_configuration dc
          WHERE dc.provider_type::text = 'APP'::text
        )
 SELECT phys_dm.client_group_name,
    phys_dm.facility_name,
    phys_dm.department_name,
    phys_dm.department_id,
    phys_dm.phys_hourly_cost,
    phys_dm.phys_peak_capacity,
    phys_dm.data_start_date,
    phys_dm.data_end_date,
    app_dm.app_hourly_cost,
    app_dm.app_peak_capacity
   FROM phys_dm
     JOIN app_dm ON phys_dm.department_id = app_dm.department_id;

ALTER TABLE public.department_metadata
    OWNER TO robertpatton;




-------------------------------------------------------------

-- FUNCTION: public.aggregated_arrivals(character varying, character varying, character varying, uuid)

CREATE FUNCTION IF NOT EXISTS public.aggregated_arrivals(
	_start_date character varying,
	_end_date character varying,
	_door_to_prov character varying,
	_dept_id uuid)
    RETURNS TABLE(id integer, dow integer, hod integer, all_avg_rvus numeric, l5cc_avg_rvus numeric) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
    ROWS 1000

AS $BODY$

DECLARE
	start_date timestamp without time zone = TO_TIMESTAMP(_start_date, 'YYYY-MM-DD HH24:MI:SS');
	end_date timestamp without time zone = TO_TIMESTAMP(_end_date, 'YYYY-MM-DD HH24:MI:SS');
	num_weeks numeric(10,2) := EXTRACT(epoch FROM (end_date - start_date))/604800.0;
	door_to_prov interval := _door_to_prov;

BEGIN

RETURN QUERY
WITH selected_adjusted_arrivals AS
(
SELECT rvus, cpt, arrival_datetime + door_to_prov AS provider_ready_time
FROM arrivals 
WHERE department_id = _dept_id
AND (arrival_datetime + door_to_prov) BETWEEN start_date AND end_date
),
all_arrivals_aggregated AS
(
SELECT EXTRACT(dow FROM provider_ready_time) AS dow,
    EXTRACT(hour FROM provider_ready_time) AS hod,
    sum(rvus) / num_weeks AS avgrvus
   FROM selected_adjusted_arrivals
  GROUP BY (EXTRACT(dow FROM provider_ready_time)), (EXTRACT(hour FROM provider_ready_time))
  ORDER BY (EXTRACT(dow FROM provider_ready_time)), (EXTRACT(hour FROM provider_ready_time))
),
level5_cc_aggregated AS
(
SELECT EXTRACT(dow FROM provider_ready_time) AS dow,
    EXTRACT(hour FROM provider_ready_time) AS hod,
    sum(rvus) / num_weeks AS avgrvus
   FROM selected_adjusted_arrivals
   WHERE (cpt::text = ANY (ARRAY['99285'::character varying, '99291'::character varying]::text[]))
  GROUP BY (EXTRACT(dow FROM provider_ready_time)), (EXTRACT(hour FROM provider_ready_time))
  ORDER BY (EXTRACT(dow FROM provider_ready_time)), (EXTRACT(hour FROM provider_ready_time))
)
SELECT (aa.dow * 100 + aa.hod)::integer AS "id",
    aa.dow::integer,
    aa.hod::integer,
    aa.avgrvus AS all_avg_rvus,
    COALESCE(la.avgrvus, 0.0) AS l5cc_avg_rvus
   FROM all_arrivals_aggregated aa
     LEFT JOIN level5_cc_aggregated la ON la.dow = aa.dow AND la.hod = aa.hod;

END

$BODY$;

ALTER FUNCTION public.aggregated_arrivals(character varying, character varying, character varying, uuid)
    OWNER TO robertpatton;



-------------------------------------------------------------




-------------------------------------------------------------


