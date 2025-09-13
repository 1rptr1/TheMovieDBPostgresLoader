CREATE TABLE IF NOT EXISTS title_akas (
    titleId TEXT,
    ordering INT,
    title TEXT,
    region TEXT,
    language TEXT,
    types TEXT,
    attributes TEXT,
    isOriginalTitle TEXT
);

COPY title_akas
FROM '/imdb_data/title.akas.tsv'
WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
