CREATE TABLE IF NOT EXISTS title_crew (
    tconst TEXT PRIMARY KEY,
    directors TEXT,
    writers TEXT
);

-- Load data with error handling for CSV parsing issues
DO $$
BEGIN
    RAISE NOTICE 'Loading data from title.crew.tsv...';
    
    -- Try to load data with CSV format first
    BEGIN
        COPY title_crew FROM '/imdb_data/title.crew.tsv' 
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        
        RAISE NOTICE 'Successfully loaded % rows into title_crew', (SELECT COUNT(*) FROM title_crew);
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'CSV format failed: %, trying text format...', SQLERRM;
            
            -- Clear any partial data
            TRUNCATE title_crew;
            
            -- Try without CSV format
            BEGIN
                COPY title_crew FROM '/imdb_data/title.crew.tsv' 
                WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
                
                RAISE NOTICE 'Successfully loaded % rows into title_crew using text format', (SELECT COUNT(*) FROM title_crew);
            EXCEPTION 
                WHEN OTHERS THEN
                    RAISE NOTICE 'Failed to load title_crew: %', SQLERRM;
                    RAISE NOTICE 'Continuing with empty title_crew table...';
            END;
    END;
END $$;
