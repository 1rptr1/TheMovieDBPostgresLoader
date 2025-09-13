CREATE TABLE IF NOT EXISTS title_episode (
    tconst TEXT PRIMARY KEY,
    parentTconst TEXT,
    seasonNumber TEXT,
    episodeNumber TEXT
);

-- Load data with error handling for CSV parsing issues
DO $$
BEGIN
    -- Check if table already has data
    IF (SELECT COUNT(*) FROM title_episode) > 0 THEN
        RAISE NOTICE 'title_episode table already contains % rows, skipping data load', (SELECT COUNT(*) FROM title_episode);
        RETURN;
    END IF;
    
    RAISE NOTICE 'Loading data from title.episode.tsv...';
    
    -- Skip CSV format entirely for title_episode due to parsing issues
    -- Try text format first (more flexible)
    BEGIN
        COPY title_episode FROM '/imdb_data/title.episode.tsv' 
        WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        
        RAISE NOTICE 'Successfully loaded % rows into title_episode using text format', (SELECT COUNT(*) FROM title_episode);
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'Text format failed: %, trying manual parsing...', SQLERRM;
            
            -- Clear any partial data
            TRUNCATE title_episode;
            
            -- Try without CSV format
            BEGIN
                COPY title_episode FROM '/imdb_data/title.episode.tsv' 
                WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
                
                RAISE NOTICE 'Successfully loaded % rows into title_episode using text format', (SELECT COUNT(*) FROM title_episode);
            EXCEPTION 
                WHEN OTHERS THEN
                    RAISE NOTICE 'Text format also failed: %, trying manual parsing...', SQLERRM;
                    
                    -- Clear any partial data
                    TRUNCATE title_episode;
                    
                    -- Manual parsing approach for malformed data
                    BEGIN
                        DROP TABLE IF EXISTS temp_title_episode;
                        CREATE TEMP TABLE temp_title_episode (line_data TEXT);
                        
                        COPY temp_title_episode FROM '/imdb_data/title.episode.tsv' 
                        WITH (FORMAT TEXT, ENCODING 'UTF8');
                        
                        INSERT INTO title_episode (tconst, parentTconst, seasonNumber, episodeNumber)
                        SELECT 
                            COALESCE(split_part(line_data, E'\t', 1), '') as tconst,
                            COALESCE(split_part(line_data, E'\t', 2), '') as parentTconst,
                            COALESCE(split_part(line_data, E'\t', 3), '') as seasonNumber,
                            COALESCE(split_part(line_data, E'\t', 4), '') as episodeNumber
                        FROM temp_title_episode 
                        WHERE line_data NOT LIKE 'tconst%'
                            AND line_data IS NOT NULL 
                            AND trim(line_data) != ''
                            AND split_part(line_data, E'\t', 1) LIKE 'tt%';
                        
                        DROP TABLE temp_title_episode;
                        RAISE NOTICE 'Successfully loaded % rows into title_episode using manual parsing', (SELECT COUNT(*) FROM title_episode);
                    EXCEPTION 
                        WHEN OTHERS THEN
                            RAISE NOTICE 'All loading methods failed for title_episode: %', SQLERRM;
                            RAISE NOTICE 'Continuing with empty title_episode table...';
                    END;
            END;
    END;
END $$;
