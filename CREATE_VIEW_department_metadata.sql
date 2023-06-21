-- View: public.department_metadata

-- DROP VIEW public.department_metadata;

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

