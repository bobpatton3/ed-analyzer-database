-- Table: public.user_department_auth

-- DROP TABLE IF EXISTS public.user_department_auth;

CREATE TABLE IF NOT EXISTS public.user_department_auth
(
    user_id uuid NOT NULL,
    department_id uuid NOT NULL,
    status character varying(31) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT user_department_auth_pkey PRIMARY KEY (user_id, department_id),
    CONSTRAINT fk_auth_department FOREIGN KEY (department_id)
        REFERENCES public.departments (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT fk_auth_user FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_department_auth
    OWNER to robertpatton;