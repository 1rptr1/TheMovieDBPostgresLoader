CREATE TABLE IF NOT EXISTS title_principals (
    tconst TEXT,
    ordering INT,
    nconst TEXT,
    category TEXT,
    job TEXT,
    characters TEXT
);

-- Try to load data, skip gracefully if file doesn't exist
DO $$
BEGIN
    -- Check if file exists first
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/title.principals.tsv')) THEN
        RAISE NOTICE 'Loading data from title.principals.tsv...';
        COPY title_principals
        FROM '/imdb_data/title.principals.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        RAISE NOTICE 'Successfully loaded % rows from title.principals.tsv', (SELECT COUNT(*) FROM title_principals);
    ELSE
        RAISE NOTICE 'File title.principals.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error loading title.principals.tsv: % - continuing with empty table', SQLERRM;
        -- Continue execution instead of failing
END $$;
