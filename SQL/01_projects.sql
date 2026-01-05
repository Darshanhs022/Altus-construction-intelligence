
CREATE TABLE projects (
    project_code TEXT PRIMARY KEY,
    project_name TEXT NOT NULL,
    location TEXT,
    project_type TEXT,
    project_start_date DATE NOT NULL,
    cut_in_date DATE NOT NULL,
    planned_completion_date DATE
);