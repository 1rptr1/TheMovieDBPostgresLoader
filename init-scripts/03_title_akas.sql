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
                    RAISE NOTICE 'Failed to load title_akas: %', SQLERRM;
                    RAISE NOTICE 'Continuing with empty title_akas table...';
            END;
    END;
END $$;
