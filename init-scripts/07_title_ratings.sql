CREATE TABLE IF NOT EXISTS title_ratings (
    tconst TEXT PRIMARY KEY,
    averageRating FLOAT,
    numVotes INT
);

-- Load data with error handling for CSV parsing issues
DO $$
BEGIN
    -- Check if table already has data
    IF (SELECT COUNT(*) FROM title_ratings) > 0 THEN
        RAISE NOTICE 'title_ratings table already contains % rows, skipping data load', (SELECT COUNT(*) FROM title_ratings);
        RETURN;
    END IF;
    
    RAISE NOTICE 'Loading data from title.ratings.tsv...';
    
    -- Try to load data with CSV format first
    BEGIN
        COPY title_ratings FROM '/imdb_data/title.ratings.tsv' 
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        
        RAISE NOTICE 'Successfully loaded % rows into title_ratings', (SELECT COUNT(*) FROM title_ratings);
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'CSV format failed: %, trying text format...', SQLERRM;
            
            -- Clear any partial data
            TRUNCATE title_ratings;
            
            -- Try without CSV format
            BEGIN
                COPY title_ratings FROM '/imdb_data/title.ratings.tsv' 
                WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
                
                RAISE NOTICE 'Successfully loaded % rows into title_ratings using text format', (SELECT COUNT(*) FROM title_ratings);
            EXCEPTION 
                WHEN OTHERS THEN
                    RAISE NOTICE 'Failed to load title_ratings: %', SQLERRM;
                    RAISE NOTICE 'Continuing with empty title_ratings table...';
            END;
    END;
END $$;
