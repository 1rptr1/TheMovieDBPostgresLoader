CREATE TABLE IF NOT EXISTS name_basics (
    nconst TEXT PRIMARY KEY,
    primaryName TEXT,
    birthYear TEXT,
    deathYear TEXT,
    primaryProfession TEXT,
    knownForTitles TEXT
);

-- Only load data if the file exists (for GitHub Actions environment)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/name.basics.tsv') WHERE size > 0) THEN
        COPY name_basics
        FROM '/imdb_data/name.basics.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
        RAISE NOTICE 'Loaded data from name.basics.tsv';
    ELSE
        RAISE NOTICE 'File name.basics.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not load name.basics.tsv - skipping data load (local development mode)';
END $$;