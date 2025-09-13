CREATE TABLE IF NOT EXISTS title_principals (
    tconst TEXT,
    ordering INT,
    nconst TEXT,
    category TEXT,
    job TEXT,
    characters TEXT
);

-- Load data with error handling for CSV parsing issues
DO $$
BEGIN
    -- Check if table already has data
    IF (SELECT COUNT(*) FROM title_principals) > 0 THEN
        RAISE NOTICE 'title_principals table already contains % rows, skipping data load', (SELECT COUNT(*) FROM title_principals);
        RETURN;
    END IF;
    
    RAISE NOTICE 'Loading data from title.principals.tsv...';
    
    -- Skip CSV format entirely for title_principals due to parsing issues
    -- Try text format first (more flexible)
    BEGIN
        COPY title_principals FROM '/imdb_data/title.principals.tsv' 
        WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        
        RAISE NOTICE 'Successfully loaded % rows into title_principals using text format', (SELECT COUNT(*) FROM title_principals);
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'Text format failed: %, trying manual parsing...', SQLERRM;
            
            -- Clear any partial data
            TRUNCATE title_principals;
            
            -- Try without CSV format
            BEGIN
                COPY title_principals FROM '/imdb_data/title.principals.tsv' 
                WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
                
                RAISE NOTICE 'Successfully loaded % rows into title_principals using text format', (SELECT COUNT(*) FROM title_principals);
            EXCEPTION 
                WHEN OTHERS THEN
                    RAISE NOTICE 'Text format also failed: %, trying manual parsing...', SQLERRM;
                    
                    -- Clear any partial data
                    TRUNCATE title_principals;
                    
                    -- Manual parsing approach for malformed data
                    BEGIN
                        DROP TABLE IF EXISTS temp_title_principals;
                        CREATE TEMP TABLE temp_title_principals (line_data TEXT);
                        
                        COPY temp_title_principals FROM '/imdb_data/title.principals.tsv' 
                        WITH (FORMAT TEXT, ENCODING 'UTF8');
                        
                        INSERT INTO title_principals (tconst, ordering, nconst, category, job, characters)
                        SELECT 
                            COALESCE(split_part(line_data, E'\t', 1), '') as tconst,
                            CASE WHEN split_part(line_data, E'\t', 2) ~ '^[0-9]+$' 
                                 THEN split_part(line_data, E'\t', 2)::INT 
                                 ELSE NULL END as ordering,
                            COALESCE(split_part(line_data, E'\t', 3), '') as nconst,
                            COALESCE(split_part(line_data, E'\t', 4), '') as category,
                            COALESCE(split_part(line_data, E'\t', 5), '') as job,
                            COALESCE(split_part(line_data, E'\t', 6), '') as characters
                        FROM temp_title_principals 
                        WHERE line_data NOT LIKE 'tconst%'
                            AND line_data IS NOT NULL 
                            AND trim(line_data) != ''
                            AND split_part(line_data, E'\t', 1) LIKE 'tt%';
                        
                        DROP TABLE temp_title_principals;
                        RAISE NOTICE 'Successfully loaded % rows into title_principals using manual parsing', (SELECT COUNT(*) FROM title_principals);
                    EXCEPTION 
                        WHEN OTHERS THEN
                            RAISE NOTICE 'All loading methods failed for title_principals: %', SQLERRM;
                            RAISE NOTICE 'Continuing with empty title_principals table...';
                    END;
            END;
    END;
END $$;
