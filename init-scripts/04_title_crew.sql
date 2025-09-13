CREATE TABLE IF NOT EXISTS title_crew (
    tconst TEXT PRIMARY KEY,
    directors TEXT,
    writers TEXT
);

-- Load data with error handling for CSV parsing issues
DO $$
BEGIN
    -- Check if table already has data
    IF (SELECT COUNT(*) FROM title_crew) > 0 THEN
        RAISE NOTICE 'title_crew table already contains % rows, skipping data load', (SELECT COUNT(*) FROM title_crew);
        RETURN;
    END IF;
    
    RAISE NOTICE 'Loading data from title.crew.tsv...';
    
    -- Skip CSV format entirely for title_crew due to parsing issues
    -- Try text format first (more flexible)
    BEGIN
        COPY title_crew FROM '/imdb_data/title.crew.tsv' 
        WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        
        RAISE NOTICE 'Successfully loaded % rows into title_crew using text format', (SELECT COUNT(*) FROM title_crew);
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'Text format failed: %, trying manual parsing...', SQLERRM;
            
            -- Clear any partial data
            TRUNCATE title_crew;
            
            -- Try without CSV format
            BEGIN
                COPY title_crew FROM '/imdb_data/title.crew.tsv' 
                WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
                
                RAISE NOTICE 'Successfully loaded % rows into title_crew using text format', (SELECT COUNT(*) FROM title_crew);
            EXCEPTION 
                WHEN OTHERS THEN
                    RAISE NOTICE 'Text format also failed: %, trying manual parsing...', SQLERRM;
                    
                    -- Clear any partial data
                    TRUNCATE title_crew;
                    
                    -- Manual parsing approach for malformed data
                    BEGIN
                        DROP TABLE IF EXISTS temp_title_crew;
                        CREATE TEMP TABLE temp_title_crew (line_data TEXT);
                        
                        COPY temp_title_crew FROM '/imdb_data/title.crew.tsv' 
                        WITH (FORMAT TEXT, ENCODING 'UTF8');
                        
                        INSERT INTO title_crew (tconst, directors, writers)
                        SELECT 
                            COALESCE(split_part(line_data, E'\t', 1), '') as tconst,
                            COALESCE(split_part(line_data, E'\t', 2), '') as directors,
                            COALESCE(split_part(line_data, E'\t', 3), '') as writers
                        FROM temp_title_crew 
                        WHERE line_data NOT LIKE 'tconst%'
                            AND line_data IS NOT NULL 
                            AND trim(line_data) != ''
                            AND split_part(line_data, E'\t', 1) LIKE 'tt%';
                        
                        DROP TABLE temp_title_crew;
                        RAISE NOTICE 'Successfully loaded % rows into title_crew using manual parsing', (SELECT COUNT(*) FROM title_crew);
                    EXCEPTION 
                        WHEN OTHERS THEN
                            RAISE NOTICE 'All loading methods failed for title_crew: %', SQLERRM;
                            RAISE NOTICE 'Continuing with empty title_crew table...';
                    END;
            END;
    END;
END $$;
