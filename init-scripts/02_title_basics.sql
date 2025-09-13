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

-- Only load data if the file exists (for GitHub Actions environment)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/title.basics.tsv') WHERE size > 0) THEN
        COPY title_basics
        FROM '/imdb_data/title.basics.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
        RAISE NOTICE 'Loaded data from title.basics.tsv';
    ELSE
        RAISE NOTICE 'File title.basics.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not load title.basics.tsv - skipping data load (local development mode)';
END $$;
