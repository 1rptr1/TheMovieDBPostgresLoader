CREATE TABLE IF NOT EXISTS title_crew (
    tconst TEXT PRIMARY KEY,
    directors TEXT,
    writers TEXT
);

-- Only load data if the file exists (for GitHub Actions environment)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/title.crew.tsv') WHERE size > 0) THEN
        COPY title_crew
        FROM '/imdb_data/title.crew.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
        RAISE NOTICE 'Loaded data from title.crew.tsv';
    ELSE
        RAISE NOTICE 'File title.crew.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not load title.crew.tsv - skipping data load (local development mode)';
END $$;
