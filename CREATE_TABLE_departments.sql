-- Table: public.departments

-- DROP TABLE IF EXISTS public.departments;

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