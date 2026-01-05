CREATE TABLE tower_floor_units (
    tower_id INTEGER NOT NULL,
    floor_level INTEGER NOT NULL,
    units INTEGER NOT NULL CHECK (units >= 0),
    CONSTRAINT pk_tower_floor PRIMARY KEY (tower_id, floor_level),
    CONSTRAINT fk_floor_tower
        FOREIGN KEY (tower_id)
        REFERENCES towers (tower_id)
);