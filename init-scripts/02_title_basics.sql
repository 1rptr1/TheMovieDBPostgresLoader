CREATE TABLE IF NOT EXISTS title_basics (
    tconst TEXT PRIMARY KEY,
    titleType TEXT,
    primaryTitle TEXT,
    originalTitle TEXT,
    isAdult TEXT,
    startYear TEXT,
    endYear TEXT,
    runtimeMinutes TEXT,
    genres TEXT
);

COPY title_basics
FROM '/data/title.basics.tsv'
WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
