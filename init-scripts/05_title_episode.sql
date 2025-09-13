CREATE TABLE IF NOT EXISTS title_episode (
    tconst TEXT PRIMARY KEY,
    parentTconst TEXT,
    seasonNumber TEXT,
    episodeNumber TEXT
);

-- Only load data if the file exists (for GitHub Actions environment)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/title.episode.tsv') WHERE size > 0) THEN
        COPY title_episode
        FROM '/imdb_data/title.episode.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
        RAISE NOTICE 'Loaded data from title.episode.tsv';
    ELSE
        RAISE NOTICE 'File title.episode.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not load title.episode.tsv - skipping data load (local development mode)';
END $$;
