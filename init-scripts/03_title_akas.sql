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

-- Try to load data, skip gracefully if file doesn't exist
DO $$
BEGIN
    COPY title_akas
    FROM '/imdb_data/title.akas.tsv'
    WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
    RAISE NOTICE 'Successfully loaded data from title.akas.tsv';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not load title.akas.tsv - skipping data load (local development mode): %', SQLERRM;
END $$;
