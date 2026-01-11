CREATE TABLE contractors (
    contractor_id SERIAL PRIMARY KEY,
    contractor_name TEXT UNIQUE NOT NULL,
    active_flag BOOLEAN NOT NULL DEFAULT TRUE
);