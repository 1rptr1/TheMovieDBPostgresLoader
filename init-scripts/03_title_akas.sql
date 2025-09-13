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

-- Try to load data, skip gracefully if file doesn't exist
DO $$
BEGIN
    -- Check if file exists first
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/title.akas.tsv')) THEN
        RAISE NOTICE 'Loading data from title.akas.tsv...';
        COPY title_akas
        FROM '/imdb_data/title.akas.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        RAISE NOTICE 'Successfully loaded % rows from title.akas.tsv', (SELECT COUNT(*) FROM title_akas);
    ELSE
        RAISE NOTICE 'File title.akas.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error loading title.akas.tsv: % - continuing with empty table', SQLERRM;
        -- Continue execution instead of failing
END $$;
