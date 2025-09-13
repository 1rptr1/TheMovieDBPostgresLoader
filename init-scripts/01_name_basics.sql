CREATE TABLE IF NOT EXISTS name_basics (
    nconst TEXT PRIMARY KEY,
    primaryName TEXT,
    birthYear TEXT,
    deathYear TEXT,
    primaryProfession TEXT,
    knownForTitles TEXT
);

-- Try to load data, skip gracefully if file doesn't exist
DO $$
BEGIN
    COPY name_basics
    FROM '/imdb_data/name.basics.tsv'
    WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
    RAISE NOTICE 'Successfully loaded data from name.basics.tsv';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not load name.basics.tsv - skipping data load (local development mode): %', SQLERRM;
END $$;