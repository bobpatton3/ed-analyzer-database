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
    CONSTRAINT schedules_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.schedules
    OWNER to robertpatton;

-- Trigger: set_uuid_trigger

-- DROP TRIGGER IF EXISTS set_uuid_trigger ON public.schedules;

CREATE TRIGGER set_uuid_trigger
    BEFORE INSERT
    ON public.schedules
    FOR EACH ROW
    EXECUTE FUNCTION public.set_uuid_field();