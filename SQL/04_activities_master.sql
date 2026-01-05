CREATE TABLE activities_master (
    activity_name TEXT PRIMARY KEY,
    category TEXT,
    dependency_activity TEXT,
    active_flag BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_dependency_activity
        FOREIGN KEY (dependency_activity)
        REFERENCES activities_master (activity_name)
);