-- FUNCTION: public.aggregated_arrivals(character varying, character varying, character varying, uuid)

-- DROP FUNCTION IF EXISTS public.aggregated_arrivals(character varying, character varying, character varying, uuid);

CREATE OR REPLACE FUNCTION public.aggregated_arrivals(
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
    la.avgrvus AS l5cc_avg_rvus
   FROM all_arrivals_aggregated aa
     JOIN level5_cc_aggregated la ON la.dow = aa.dow AND la.hod = aa.hod;

END

$BODY$;

ALTER FUNCTION public.aggregated_arrivals(character varying, character varying, character varying, uuid)
    OWNER TO robertpatton;
