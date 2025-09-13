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
    RAISE NOTICE 'Loading data from title.principals.tsv...';
    
    -- Try to load data with CSV format first
    BEGIN
        COPY title_principals FROM '/imdb_data/title.principals.tsv' 
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        
        RAISE NOTICE 'Successfully loaded % rows into title_principals', (SELECT COUNT(*) FROM title_principals);
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'CSV format failed: %, trying text format...', SQLERRM;
            
            -- Clear any partial data
            TRUNCATE title_principals;
            
            -- Try without CSV format
            BEGIN
                COPY title_principals FROM '/imdb_data/title.principals.tsv' 
                WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
                
                RAISE NOTICE 'Successfully loaded % rows into title_principals using text format', (SELECT COUNT(*) FROM title_principals);
            EXCEPTION 
                WHEN OTHERS THEN
                    RAISE NOTICE 'Failed to load title_principals: %', SQLERRM;
                    RAISE NOTICE 'Continuing with empty title_principals table...';
            END;
    END;
END $$;
