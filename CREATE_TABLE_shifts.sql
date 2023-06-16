-- Table: public.shifts

-- DROP TABLE IF EXISTS public.shifts;

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