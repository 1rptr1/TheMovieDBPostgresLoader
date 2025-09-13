CREATE TABLE IF NOT EXISTS name_basics (
    nconst TEXT PRIMARY KEY,
    primaryName TEXT,
    birthYear TEXT,
    deathYear TEXT,
    primaryProfession TEXT,
    knownForTitles TEXT
);

-- Try to load data, skip gracefully if file doesn't exist
DO $$
BEGIN
    -- Check if file exists first
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/name.basics.tsv')) THEN
        RAISE NOTICE 'Loading data from name.basics.tsv...';
        COPY name_basics
        FROM '/imdb_data/name.basics.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        RAISE NOTICE 'Successfully loaded % rows from name.basics.tsv', (SELECT COUNT(*) FROM name_basics);
    ELSE
        RAISE NOTICE 'File name.basics.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error loading name.basics.tsv: % - continuing with empty table', SQLERRM;
        -- Continue execution instead of failing
END $$;