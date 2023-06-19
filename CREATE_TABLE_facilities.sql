-- Table: public.facilities

-- DROP TABLE IF EXISTS public.facilities;

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