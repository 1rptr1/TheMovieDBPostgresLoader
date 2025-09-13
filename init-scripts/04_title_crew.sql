CREATE TABLE IF NOT EXISTS title_crew (
    tconst TEXT PRIMARY KEY,
    directors TEXT,
    writers TEXT
);

-- Try to load data, skip gracefully if file doesn't exist
DO $$
BEGIN
    -- Check if file exists first
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/title.crew.tsv')) THEN
        RAISE NOTICE 'Loading data from title.crew.tsv...';
        COPY title_crew
        FROM '/imdb_data/title.crew.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        RAISE NOTICE 'Successfully loaded % rows from title.crew.tsv', (SELECT COUNT(*) FROM title_crew);
    ELSE
        RAISE NOTICE 'File title.crew.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error loading title.crew.tsv: % - continuing with empty table', SQLERRM;
        -- Continue execution instead of failing
END $$;
