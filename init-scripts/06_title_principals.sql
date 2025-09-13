CREATE TABLE IF NOT EXISTS title_principals (
    tconst TEXT,
    ordering INT,
    nconst TEXT,
    category TEXT,
    job TEXT,
    characters TEXT
);

-- Only load data if the file exists (for GitHub Actions environment)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/title.principals.tsv') WHERE size > 0) THEN
        COPY title_principals
        FROM '/imdb_data/title.principals.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
        RAISE NOTICE 'Loaded data from title.principals.tsv';
    ELSE
        RAISE NOTICE 'File title.principals.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not load title.principals.tsv - skipping data load (local development mode)';
END $$;
