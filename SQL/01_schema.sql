CREATE TABLE projects (
    project_code TEXT PRIMARY KEY,
    project_name TEXT NOT NULL,
    location TEXT,
    project_type TEXT,
    project_start_date DATE NOT NULL,
    cut_in_date DATE NOT NULL,
    planned_completion_date DATE
);
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
CREATE TABLE tower_floor_units (
	project_code TEXT NOT NULL,
	tower_name TEXT NOT NULL,
    floor_level INTEGER NOT NULL,
    units INTEGER NOT NULL CHECK (units >= 0),
	CONSTRAINT pk_tower_floor 
        PRIMARY KEY (project_code, tower_name, floor_level),
    CONSTRAINT fk_floor_tower
        FOREIGN KEY (project_code, tower_name)
        REFERENCES towers (project_code, tower_name)
);
CREATE TABLE activities_master (
    activity_name TEXT PRIMARY KEY,
    category TEXT,
    dependency_activity TEXT,
    active_flag BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_dependency_activity
        FOREIGN KEY (dependency_activity)
        REFERENCES activities_master (activity_name)
);

CREATE TABLE contractors (
    contractor_id SERIAL PRIMARY KEY,
    contractor_name TEXT UNIQUE NOT NULL,
    active_flag BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE contractor_activity_map (
    cam_id SERIAL PRIMARY KEY,
    project_code TEXT NOT NULL,
    tower_name TEXT NOT NULL,
    activity_name TEXT NOT NULL,
    contractor_name TEXT,
    effective_from_date DATE,
    effective_to_date DATE,
    active_flag BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_cam_project
        FOREIGN KEY (project_code)
        REFERENCES projects (project_code),
	CONSTRAINT fk_cam_tower
        FOREIGN KEY (project_code, tower_name)
        REFERENCES towers (project_code, tower_name),
    CONSTRAINT fk_cam_activity
        FOREIGN KEY (activity_name)
        REFERENCES activities_master (activity_name),
    CONSTRAINT fk_cam_contractor
        FOREIGN KEY (contractor_name)
        REFERENCES contractors(contractor_name)
);

CREATE TABLE mcp_dates (
    project_code TEXT NOT NULL,
    tower_name TEXT NOT NULL,
    floor_level INTEGER NOT NULL,
    activity_name TEXT NOT NULL,
    planned_date DATE NOT NULL,
    CONSTRAINT pk_mcp PRIMARY KEY (project_code, tower_name, floor_level, activity_name),
    CONSTRAINT fk_mcp_project
        FOREIGN KEY (project_code)
        REFERENCES projects (project_code),
	CONSTRAINT fk_mcp_tower
        FOREIGN KEY (project_code, tower_name)
        REFERENCES towers (project_code, tower_name),
    CONSTRAINT fk_mcp_activity
        FOREIGN KEY (activity_name)
        REFERENCES activities_master (activity_name)
);

CREATE TABLE monthly_planned_units (
    project_code VARCHAR(20) NOT NULL,
    tower_name   VARCHAR(20) NOT NULL,
    activity_name VARCHAR(50) NOT NULL,
    plan_month DATE NOT NULL,
    planned_units INT NOT NULL,
    uploaded_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (project_code, tower_name, activity_name, plan_month)
);

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

CREATE TABLE raw_progress_input (
    raw_id SERIAL PRIMARY KEY,
    project_code TEXT NOT NULL,
    tower_name TEXT NOT NULL,
    floor_level INTEGER NOT NULL,
    activity_name TEXT NOT NULL,
    completed_units INTEGER NOT NULL CHECK (completed_units >= 0),
    entry_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

