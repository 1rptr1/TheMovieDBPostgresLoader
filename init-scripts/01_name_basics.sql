CREATE TABLE IF NOT EXISTS name_basics (
    nconst TEXT PRIMARY KEY,
    primaryName TEXT,
    birthYear TEXT,
    deathYear TEXT,
    primaryProfession TEXT,
    knownForTitles TEXT
);

COPY name_basics
FROM '/imdb_data/name.basics.tsv'
WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');