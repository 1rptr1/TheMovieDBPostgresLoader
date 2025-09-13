CREATE TABLE IF NOT EXISTS title_crew (
    tconst TEXT PRIMARY KEY,
    directors TEXT,
    writers TEXT
);

COPY title_crew
FROM '/imdb_data/title.crew.tsv'
WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
