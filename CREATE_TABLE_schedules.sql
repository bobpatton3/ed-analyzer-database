-- Table: public.schedules

-- DROP TABLE IF EXISTS public.schedules;

CREATE TABLE IF NOT EXISTS public.schedules
(
    id uuid NOT NULL,
    creation_date date,
    update_date date,
    owner character varying(31) COLLATE pg_catalog."default" NOT NULL,
    schedule_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    client_group character varying(255) COLLATE pg_catalog."default",
    facility character varying(255) COLLATE pg_catalog."default",
    department character varying(255) COLLATE pg_catalog."default",
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