CREATE TABLE public.stg_companies (
    name                   TEXT NOT NULL,
    company_linkedin_names TEXT[],
    description            TEXT,
    headcount              INTEGER,
    founding_date          DATE,
    most_recent_raise      FLOAT,
    most_recent_valuation  FLOAT,
    investors              TEXT[],
    known_total_funding    FLOAT
);

CREATE TABLE public.stg_people (
    person_id         TEXT NOT NULL,
    company_name      TEXT,
    company_li_name   TEXT,
    last_title        TEXT,
    group_start_date  DATE,
    group_end_date    DATE
);

CREATE TABLE public.companies (
    name                   TEXT NOT NULL,
    company_linkedin_names TEXT[],
    description            TEXT,
    headcount              INTEGER,
    founding_date          DATE,
    most_recent_raise      FLOAT,
    most_recent_valuation  FLOAT,
    investors              TEXT[],
    known_total_funding    FLOAT,
    CONSTRAINT companies_pk PRIMARY KEY (name)
);

CREATE TABLE public.people (
    person_id         TEXT NOT NULL,
    company_name      TEXT,
    company_li_name   TEXT,
    last_title        TEXT,
    group_start_date  DATE,
    group_end_date    DATE,
    CONSTRAINT people_pk PRIMARY KEY (person_id, company_name)
);