CREATE TABLE IF NOT EXISTS title_episode (
    tconst TEXT PRIMARY KEY,
    parentTconst TEXT,
    seasonNumber TEXT,
    episodeNumber TEXT
);

-- Load data with error handling for CSV parsing issues
DO $$
BEGIN
    -- Check if table already has data
    IF (SELECT COUNT(*) FROM title_episode) > 0 THEN
        RAISE NOTICE 'title_episode table already contains % rows, skipping data load', (SELECT COUNT(*) FROM title_episode);
        RETURN;
    END IF;
    
    RAISE NOTICE 'Loading data from title.episode.tsv...';
    
    -- Try to load data with CSV format first
    BEGIN
        COPY title_episode FROM '/imdb_data/title.episode.tsv' 
        WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
        
        RAISE NOTICE 'Successfully loaded % rows into title_episode', (SELECT COUNT(*) FROM title_episode);
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'CSV format failed: %, trying text format...', SQLERRM;
            
            -- Clear any partial data
            TRUNCATE title_episode;
            
            -- Try without CSV format
            BEGIN
                COPY title_episode FROM '/imdb_data/title.episode.tsv' 
                WITH (DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
                
                RAISE NOTICE 'Successfully loaded % rows into title_episode using text format', (SELECT COUNT(*) FROM title_episode);
            EXCEPTION 
                WHEN OTHERS THEN
                    RAISE NOTICE 'Failed to load title_episode: %', SQLERRM;
                    RAISE NOTICE 'Continuing with empty title_episode table...';
            END;
    END;
END $$;
