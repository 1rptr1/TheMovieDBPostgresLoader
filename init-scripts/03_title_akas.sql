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

-- Load data with error handling for CSV parsing issues
DO $$
BEGIN
    -- Check if table already has data
    IF (SELECT COUNT(*) FROM title_akas) > 0 THEN
        RAISE NOTICE 'title_akas table already contains % rows, skipping data load', (SELECT COUNT(*) FROM title_akas);
        RETURN;
    END IF;
    
    RAISE NOTICE 'Loading data from title.akas.tsv...';
    
    -- Try to load data with CSV format first
    BEGIN
        COPY title_akas FROM '/imdb_data/title.akas.tsv' 
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        
        RAISE NOTICE 'Successfully loaded % rows into title_akas', (SELECT COUNT(*) FROM title_akas);
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'CSV format failed: %, trying text format...', SQLERRM;
            
            -- Clear any partial data
            TRUNCATE title_akas;
            
            -- Try without CSV format
            BEGIN
                COPY title_akas FROM '/imdb_data/title.akas.tsv' 
                WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
                
                RAISE NOTICE 'Successfully loaded % rows into title_akas using text format', (SELECT COUNT(*) FROM title_akas);
            EXCEPTION 
                WHEN OTHERS THEN
                    RAISE NOTICE 'Text format also failed: %, trying manual parsing...', SQLERRM;
                    
                    -- Clear any partial data
                    TRUNCATE title_akas;
                    
                    -- Manual parsing approach for malformed data
                    BEGIN
                        DROP TABLE IF EXISTS temp_title_akas;
                        CREATE TEMP TABLE temp_title_akas (line_data TEXT);
                        
                        COPY temp_title_akas FROM '/imdb_data/title.akas.tsv' 
                        WITH (FORMAT TEXT, ENCODING 'UTF8');
                        
                        INSERT INTO title_akas (titleId, ordering, title, region, language, types, attributes, isOriginalTitle)
                        SELECT 
                            COALESCE(split_part(line_data, E'\t', 1), '') as titleId,
                            CASE WHEN split_part(line_data, E'\t', 2) ~ '^[0-9]+$' 
                                 THEN split_part(line_data, E'\t', 2)::INT 
                                 ELSE NULL END as ordering,
                            COALESCE(split_part(line_data, E'\t', 3), '') as title,
                            COALESCE(split_part(line_data, E'\t', 4), '') as region,
                            COALESCE(split_part(line_data, E'\t', 5), '') as language,
                            COALESCE(split_part(line_data, E'\t', 6), '') as types,
                            COALESCE(split_part(line_data, E'\t', 7), '') as attributes,
                            COALESCE(split_part(line_data, E'\t', 8), '') as isOriginalTitle
                        FROM temp_title_akas 
                        WHERE line_data NOT LIKE 'titleId%'
                            AND line_data IS NOT NULL 
                            AND trim(line_data) != ''
                            AND split_part(line_data, E'\t', 1) LIKE 'tt%';
                        
                        DROP TABLE temp_title_akas;
                        RAISE NOTICE 'Successfully loaded % rows into title_akas using manual parsing', (SELECT COUNT(*) FROM title_akas);
                    EXCEPTION 
                        WHEN OTHERS THEN
                            RAISE NOTICE 'All loading methods failed for title_akas: %', SQLERRM;
                            RAISE NOTICE 'Continuing with empty title_akas table...';
                    END;
            END;
    END;
END $$;
