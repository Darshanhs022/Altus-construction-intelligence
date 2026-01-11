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