CREATE TABLE IF NOT EXISTS title_principals (
    tconst TEXT,
    ordering INT,
    nconst TEXT,
    category TEXT,
    job TEXT,
    characters TEXT
);

COPY title_principals
FROM '/imdb_data/title.principals.tsv'
WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
