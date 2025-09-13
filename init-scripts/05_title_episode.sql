CREATE TABLE IF NOT EXISTS title_episode (
    tconst TEXT PRIMARY KEY,
    parentTconst TEXT,
    seasonNumber TEXT,
    episodeNumber TEXT
);

-- Try to load data, skip gracefully if file doesn't exist
DO $$
BEGIN
    COPY title_episode
    FROM '/imdb_data/title.episode.tsv'
    WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
    RAISE NOTICE 'Successfully loaded data from title.episode.tsv';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not load title.episode.tsv - skipping data load (local development mode): %', SQLERRM;
END $$;
