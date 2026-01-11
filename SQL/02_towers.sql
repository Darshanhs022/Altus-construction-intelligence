CREATE TABLE towers (
    tower_id SERIAL PRIMARY KEY,
    project_code TEXT NOT NULL,
    tower_name TEXT NOT NULL,
    total_floors INTEGER NOT NULL,
	total_units INTEGER NOT NULL,
    CONSTRAINT uq_project_tower UNIQUE (project_code, tower_name),
    CONSTRAINT fk_towers_project
        FOREIGN KEY (project_code)
        REFERENCES projects (project_code)
);