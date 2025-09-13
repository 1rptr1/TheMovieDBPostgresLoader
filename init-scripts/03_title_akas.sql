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

-- Only load data if the file exists (for GitHub Actions environment)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/title.akas.tsv') WHERE size > 0) THEN
        COPY title_akas
        FROM '/imdb_data/title.akas.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
        RAISE NOTICE 'Loaded data from title.akas.tsv';
    ELSE
        RAISE NOTICE 'File title.akas.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not load title.akas.tsv - skipping data load (local development mode)';
END $$;
