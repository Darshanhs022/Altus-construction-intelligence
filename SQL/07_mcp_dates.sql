CREATE TABLE mcp_dates (
    project_code TEXT NOT NULL,
    tower_id INTEGER NOT NULL,
    floor_level INTEGER NOT NULL,
    activity_name TEXT NOT NULL,
    planned_date DATE NOT NULL,
    CONSTRAINT pk_mcp PRIMARY KEY (project_code, tower_id, floor_level, activity_name),
    CONSTRAINT fk_mcp_project
        FOREIGN KEY (project_code)
        REFERENCES projects (project_code),
    CONSTRAINT fk_mcp_tower
        FOREIGN KEY (tower_id)
        REFERENCES towers (tower_id),
    CONSTRAINT fk_mcp_activity
        FOREIGN KEY (activity_name)
        REFERENCES activities_master (activity_name)
);