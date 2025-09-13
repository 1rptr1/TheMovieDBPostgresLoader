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
    RAISE NOTICE 'Loading data from title.basics.tsv...';
    
    -- Try to load data normally first
    BEGIN
        COPY title_basics FROM '/imdb_data/title.basics.tsv' 
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        
        RAISE NOTICE 'Successfully loaded % rows into title_basics', (SELECT COUNT(*) FROM title_basics);
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'CSV format failed: %, trying text format with error tolerance...', SQLERRM;
            
            -- Clear any partial data
            TRUNCATE title_basics;
            
            -- Try without CSV format to handle malformed rows
            BEGIN
                COPY title_basics FROM '/imdb_data/title.basics.tsv' 
                WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
                
                RAISE NOTICE 'Successfully loaded % rows into title_basics using text format', (SELECT COUNT(*) FROM title_basics);
            EXCEPTION 
                WHEN OTHERS THEN
                    RAISE NOTICE 'Failed to load title_basics: %', SQLERRM;
                    RAISE NOTICE 'Continuing with empty title_basics table...';
            END;
    END;
END $$;
