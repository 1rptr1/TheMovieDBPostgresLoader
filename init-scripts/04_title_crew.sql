CREATE TABLE IF NOT EXISTS title_crew (
    tconst TEXT PRIMARY KEY,
    directors TEXT,
    writers TEXT
);

-- Try to load data, skip gracefully if file doesn't exist
DO $$
BEGIN
    COPY title_crew
    FROM '/imdb_data/title.crew.tsv'
    WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
    RAISE NOTICE 'Successfully loaded data from title.crew.tsv';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not load title.crew.tsv - skipping data load (local development mode): %', SQLERRM;
END $$;
