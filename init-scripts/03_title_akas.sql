-- 03_title_akas.sql
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

DO $$
BEGIN
    -- Skip if already loaded
    IF (SELECT COUNT(*) FROM title_akas) > 0 THEN
        RAISE NOTICE 'title_akas already contains % rows, skipping load', (SELECT COUNT(*) FROM title_akas);
        RETURN;
    END IF;

    RAISE NOTICE 'Loading data from title.akas.tsv...';

    BEGIN
        COPY title_akas
        FROM '/imdb_data/title.akas.tsv'
        WITH (FORMAT text, DELIMITER E'\t', NULL '\N', HEADER true, ENCODING 'UTF8');

        RAISE NOTICE 'Successfully loaded % rows into title_akas (text format)',
            (SELECT COUNT(*) FROM title_akas);

    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Text COPY failed: %, falling back to manual parsing', SQLERRM;

        TRUNCATE title_akas;

        CREATE TEMP TABLE temp_title_akas (line_data TEXT);

        COPY temp_title_akas FROM '/imdb_data/title.akas.tsv' WITH (FORMAT text, ENCODING 'UTF8');

        INSERT INTO title_akas (titleId, ordering, title, region, language, types, attributes, isOriginalTitle)
        SELECT
            split_part(line_data, E'\t', 1),
            NULLIF(split_part(line_data, E'\t', 2), '')::INT,
            split_part(line_data, E'\t', 3),
            split_part(line_data, E'\t', 4),
            split_part(line_data, E'\t', 5),
            split_part(line_data, E'\t', 6),
            split_part(line_data, E'\t', 7),
            split_part(line_data, E'\t', 8)
        FROM temp_title_akas
        WHERE line_data NOT LIKE 'titleId%'
          AND line_data IS NOT NULL
          AND trim(line_data) <> '';

        DROP TABLE temp_title_akas;

        RAISE NOTICE 'Successfully loaded % rows into title_akas (manual parsing)',
            (SELECT COUNT(*) FROM title_akas);
    END;
END $$;
