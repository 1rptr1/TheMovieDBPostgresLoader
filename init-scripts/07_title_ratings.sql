CREATE TABLE IF NOT EXISTS title_ratings (
    tconst TEXT PRIMARY KEY,
    averageRating FLOAT,
    numVotes INT
);

-- Try to load data, skip gracefully if file doesn't exist
DO $$
BEGIN
    COPY title_ratings
    FROM '/imdb_data/title.ratings.tsv'
    WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
    RAISE NOTICE 'Successfully loaded data from title.ratings.tsv';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not load title.ratings.tsv - skipping data load (local development mode): %', SQLERRM;
END $$;
