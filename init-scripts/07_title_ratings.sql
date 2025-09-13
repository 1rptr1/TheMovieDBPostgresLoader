CREATE TABLE IF NOT EXISTS title_ratings (
    tconst TEXT PRIMARY KEY,
    averageRating FLOAT,
    numVotes INT
);

-- Try to load data, skip gracefully if file doesn't exist
DO $$
BEGIN
    -- Check if file exists first
    IF EXISTS (SELECT 1 FROM pg_stat_file('/imdb_data/title.ratings.tsv')) THEN
        RAISE NOTICE 'Loading data from title.ratings.tsv...';
        COPY title_ratings
        FROM '/imdb_data/title.ratings.tsv'
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        RAISE NOTICE 'Successfully loaded % rows from title.ratings.tsv', (SELECT COUNT(*) FROM title_ratings);
    ELSE
        RAISE NOTICE 'File title.ratings.tsv not found - skipping data load (local development mode)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error loading title.ratings.tsv: % - continuing with empty table', SQLERRM;
        -- Continue execution instead of failing
END $$;
