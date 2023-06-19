-- Table: public.department_configuration

-- DROP TABLE IF EXISTS public.department_configuration;

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