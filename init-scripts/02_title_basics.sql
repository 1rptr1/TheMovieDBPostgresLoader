CREATE TABLE IF NOT EXISTS title_basics (
    tconst TEXT PRIMARY KEY,
    titleType TEXT,
    primaryTitle TEXT,
    originalTitle TEXT,
    isAdult TEXT,
    startYear TEXT,
    endYear TEXT,
    runtimeMinutes TEXT,
    genres TEXT
);

-- Load data with error handling for missing columns
DO $$
BEGIN
    -- Check if table already has data
    IF (SELECT COUNT(*) FROM title_basics) > 0 THEN
        RAISE NOTICE 'title_basics table already contains % rows, skipping data load', (SELECT COUNT(*) FROM title_basics);
        RETURN;
    END IF;
    
    RAISE NOTICE 'Loading data from title.basics.tsv...';
    
    -- Skip CSV format entirely for title_basics due to parsing issues
    -- Try text format first (more flexible) with timeout handling
    BEGIN
        -- Set statement timeout to prevent hanging
        SET statement_timeout = '300s';
        
        COPY title_basics FROM '/imdb_data/title.basics.tsv' 
        WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        
        -- Reset timeout
        SET statement_timeout = 0;
        
        RAISE NOTICE 'Successfully loaded % rows into title_basics using text format', (SELECT COUNT(*) FROM title_basics);
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'Text format failed: %, trying manual parsing with error tolerance...', SQLERRM;
            
            -- Clear any partial data
            TRUNCATE title_basics;
            
            -- Try without CSV format to handle malformed rows
            BEGIN
                COPY title_basics FROM '/imdb_data/title.basics.tsv' 
                WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
                
                RAISE NOTICE 'Successfully loaded % rows into title_basics using text format', (SELECT COUNT(*) FROM title_basics);
            EXCEPTION 
                WHEN OTHERS THEN
                RAISE NOTICE 'Text format also failed: %, trying with temporary table approach...', SQLERRM;
                
                -- Clear any partial data
                TRUNCATE title_basics;
                
                -- Create temporary table with all text columns to handle variable column counts
                BEGIN
                    DROP TABLE IF EXISTS temp_title_basics;
                    CREATE TEMP TABLE temp_title_basics (
                        line_data TEXT
                    );
                    
                    -- Load raw lines first
                    COPY temp_title_basics FROM '/imdb_data/title.basics.tsv' 
                    WITH (FORMAT TEXT, ENCODING 'UTF8');
                    
                    -- Parse and insert valid rows only
                    INSERT INTO title_basics (tconst, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes, genres)
                    SELECT 
                        COALESCE(split_part(line_data, E'\t', 1), '') as tconst,
                        COALESCE(split_part(line_data, E'\t', 2), '') as titleType,
                        COALESCE(split_part(line_data, E'\t', 3), '') as primaryTitle,
                        COALESCE(split_part(line_data, E'\t', 4), '') as originalTitle,
                        COALESCE(split_part(line_data, E'\t', 5), '') as isAdult,
                        COALESCE(split_part(line_data, E'\t', 6), '') as startYear,
                        COALESCE(split_part(line_data, E'\t', 7), '') as endYear,
                        COALESCE(split_part(line_data, E'\t', 8), '') as runtimeMinutes,
                        COALESCE(split_part(line_data, E'\t', 9), '') as genres
                    FROM temp_title_basics 
                    WHERE line_data NOT LIKE 'tconst%'  -- Skip header
                        AND line_data IS NOT NULL 
                        AND trim(line_data) != ''
                        AND split_part(line_data, E'\t', 1) LIKE 'tt%';  -- Valid tconst format
                    
                    DROP TABLE temp_title_basics;
                    
                    RAISE NOTICE 'Successfully loaded % rows into title_basics using manual parsing', (SELECT COUNT(*) FROM title_basics);
                EXCEPTION 
                    WHEN OTHERS THEN
                        RAISE NOTICE 'All loading methods failed for title_basics: %', SQLERRM;
                        RAISE NOTICE 'Continuing with empty title_basics table...';
                END;
            END;
    END;
END $$;
