CREATE TABLE IF NOT EXISTS title_episode (
    tconst TEXT PRIMARY KEY,
    parentTconst TEXT,
    seasonNumber TEXT,
    episodeNumber TEXT
);

-- Try to load data, skip gracefully if file doesn't exist
DO $$
BEGIN
    -- Check if file exists first
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/title.episode.tsv')) THEN
        RAISE NOTICE 'Loading data from title.episode.tsv...';
        COPY title_episode
        FROM '/imdb_data/title.episode.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        RAISE NOTICE 'Successfully loaded % rows from title.episode.tsv', (SELECT COUNT(*) FROM title_episode);
    ELSE
        RAISE NOTICE 'File title.episode.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error loading title.episode.tsv: % - continuing with empty table', SQLERRM;
        -- Continue execution instead of failing
END $$;
