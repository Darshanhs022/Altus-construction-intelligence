CREATE TABLE baseline_progress (
    project_code TEXT NOT NULL,
    tower_name TEXT NOT NULL,
    floor_level INTEGER NOT NULL,
    activity_name TEXT NOT NULL,
    completed_units INTEGER NOT NULL CHECK (completed_units >= 0),
    CONSTRAINT pk_baseline PRIMARY KEY (project_code, tower_name, floor_level, activity_name),
    CONSTRAINT fk_baseline_project
        FOREIGN KEY (project_code)
        REFERENCES projects (project_code),
    CONSTRAINT fk_baseline_tower
        FOREIGN KEY (project_code, tower_name)
        REFERENCES towers (project_code, tower_name),
    CONSTRAINT fk_baseline_activity
        FOREIGN KEY (activity_name)
        REFERENCES activities_master (activity_name)
);