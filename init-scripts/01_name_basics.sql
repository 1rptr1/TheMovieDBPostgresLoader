CREATE TABLE IF NOT EXISTS name_basics (
    nconst TEXT PRIMARY KEY,
    primaryName TEXT,
    birthYear TEXT,
    deathYear TEXT,
    primaryProfession TEXT,
    knownForTitles TEXT
);

-- Load data with error handling for CSV parsing issues
DO $$
BEGIN
    -- Check if table already has data
    IF (SELECT COUNT(*) FROM name_basics) > 0 THEN
        RAISE NOTICE 'name_basics table already contains % rows, skipping data load', (SELECT COUNT(*) FROM name_basics);
        RETURN;
    END IF;
    
    RAISE NOTICE 'Loading data from name.basics.tsv...';
    
    -- Try to load data with QUOTE handling for malformed quotes
    BEGIN
        COPY name_basics FROM '/imdb_data/name.basics.tsv' 
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8', QUOTE '"', ESCAPE '"');
        
        RAISE NOTICE 'Successfully loaded % rows into name_basics', (SELECT COUNT(*) FROM name_basics);
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'First attempt failed: %, trying with different CSV options...', SQLERRM;
            
            -- Clear any partial data
            TRUNCATE name_basics;
            
            -- Try without CSV format (treat as raw text with tab delimiter)
            BEGIN
                COPY name_basics FROM '/imdb_data/name.basics.tsv' 
                WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
                
                RAISE NOTICE 'Successfully loaded % rows into name_basics using text format', (SELECT COUNT(*) FROM name_basics);
            EXCEPTION 
                WHEN OTHERS THEN
                    RAISE NOTICE 'Failed to load name_basics: %', SQLERRM;
                    RAISE NOTICE 'Continuing with empty name_basics table...';
            END;
    END;
END $$;