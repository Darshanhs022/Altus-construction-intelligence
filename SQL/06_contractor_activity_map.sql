CREATE TABLE contractor_activity_map (
    cam_id SERIAL PRIMARY KEY,
    project_code TEXT NOT NULL,
    tower_id INTEGER NOT NULL,
    activity_name TEXT NOT NULL,
    contractor_id INTEGER NOT NULL,
    effective_from_date DATE,
    effective_to_date DATE,
    active_flag BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_cam_project
        FOREIGN KEY (project_code)
        REFERENCES projects (project_code),
    CONSTRAINT fk_cam_tower
        FOREIGN KEY (tower_id)
        REFERENCES towers (tower_id),
    CONSTRAINT fk_cam_activity
        FOREIGN KEY (activity_name)
        REFERENCES activities_master (activity_name),
    CONSTRAINT fk_cam_contractor
        FOREIGN KEY (contractor_id)
        REFERENCES contractors(contractor_id)
);