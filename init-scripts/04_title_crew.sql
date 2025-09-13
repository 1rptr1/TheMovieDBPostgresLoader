DO $$
DECLARE
    batch_size INT := 500000;
    offset_val INT := 0;
    total_rows BIGINT;
BEGIN
    -- Skip if already loaded
    IF (SELECT COUNT(*) FROM title_episode) > 0 THEN
        RAISE NOTICE 'title_episode already contains % rows, skipping load', (SELECT COUNT(*) FROM title_episode);
        RETURN;
    END IF;

    RAISE NOTICE 'Loading data from title.episode.tsv in batches of % rows...', batch_size;

    CREATE TEMP TABLE temp_episode (LIKE title_episode);

    COPY temp_episode
    FROM '/imdb_data/title.episode.tsv'
    WITH (FORMAT text, DELIMITER E'\t', NULL '\N', HEADER true, ENCODING 'UTF8');

    LOOP
        INSERT INTO title_episode
        SELECT * FROM temp_episode
        WHERE ctid IN (
            SELECT ctid FROM temp_episode
            LIMIT batch_size OFFSET offset_val
        );

        GET DIAGNOSTICS total_rows = ROW_COUNT;

        EXIT WHEN total_rows = 0;

        offset_val := offset_val + batch_size;
        RAISE NOTICE 'Inserted batch ending at row %', offset_val;
        -- ❌ removed COMMIT / BEGIN, not allowed inside DO
    END LOOP;

    DROP TABLE temp_episode;

    RAISE NOTICE 'Finished loading % rows into title_episode',
        (SELECT COUNT(*) FROM title_episode);
END $$;
