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

-- Try to load data, skip gracefully if file doesn't exist
DO $$
BEGIN
    COPY title_basics
    FROM '/imdb_data/title.basics.tsv'
    WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
    RAISE NOTICE 'Successfully loaded data from title.basics.tsv';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not load title.basics.tsv - skipping data load (local development mode): %', SQLERRM;
END $$;
