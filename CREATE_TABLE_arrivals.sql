-- Table: public.arrivals

-- DROP TABLE IF EXISTS public.arrivals;

CREATE TABLE IF NOT EXISTS public.arrivals
(
    client_group character varying(255) COLLATE pg_catalog."default",
    facility character varying(255) COLLATE pg_catalog."default",
    department character varying(255) COLLATE pg_catalog."default",
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