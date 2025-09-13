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
    -- Check if file exists first
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/title.basics.tsv')) THEN
        RAISE NOTICE 'Loading data from title.basics.tsv...';
        COPY title_basics
        FROM '/imdb_data/title.basics.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        RAISE NOTICE 'Successfully loaded % rows from title.basics.tsv', (SELECT COUNT(*) FROM title_basics);
    ELSE
        RAISE NOTICE 'File title.basics.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error loading title.basics.tsv: % - continuing with empty table', SQLERRM;
        -- Continue execution instead of failing
END $$;
