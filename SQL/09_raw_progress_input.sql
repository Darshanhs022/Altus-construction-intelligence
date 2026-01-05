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