-- Table: public.client_groups

-- DROP TABLE IF EXISTS public.client_groups;

CREATE TABLE IF NOT EXISTS public.client_groups
(
    id uuid NOT NULL,
    client_group_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT client_groups_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.client_groups
    OWNER to robertpatton;