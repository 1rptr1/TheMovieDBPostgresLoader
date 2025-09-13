-- Find all movies with Chris Hemsworth
-- This query adapts based on available data

-- Data Status Check (lightweight)
SELECT 
    'Data Status Check:' as info,
    CASE WHEN EXISTS(SELECT 1 FROM name_basics LIMIT 1) THEN 'HAS_DATA' ELSE 'EMPTY' END as name_basics_status,
    CASE WHEN EXISTS(SELECT 1 FROM title_basics LIMIT 1) THEN 'HAS_DATA' ELSE 'EMPTY' END as title_basics_status,
    CASE WHEN EXISTS(SELECT 1 FROM title_principals LIMIT 1) THEN 'HAS_DATA' ELSE 'EMPTY' END as title_principals_status;

-- Chris Hemsworth Basic Info (Always works)
SELECT 
    'Chris Hemsworth Info:' as section,
    nconst, 
    primaryName, 
    birthYear, 
    primaryProfession, 
    knownForTitles
FROM name_basics 
WHERE primaryName ILIKE '%Chris Hemsworth%';

-- Full Movie Query (Only if all tables have data)
DO $$
BEGIN
    IF EXISTS(SELECT 1 FROM title_basics LIMIT 1) AND EXISTS(SELECT 1 FROM title_principals LIMIT 1) THEN
        RAISE NOTICE 'Running full Chris Hemsworth movie query...';
        
        -- This would be executed as a separate query:
        -- SELECT DISTINCT tb.primaryTitle, tb.startYear, tb.genres, tb.titleType
        -- FROM name_basics nb
        -- JOIN title_principals tp ON nb.nconst = tp.nconst
        -- JOIN title_basics tb ON tp.tconst = tb.tconst
        -- WHERE nb.primaryName ILIKE '%Chris Hemsworth%'
        --   AND tb.titleType IN ('movie', 'tvMovie')
        -- ORDER BY tb.startYear DESC;
        
    ELSE
        RAISE NOTICE 'Full movie data not available. Using lightweight check instead of COUNT queries.';
    END IF;
END $$;

-- If title_basics and title_principals have data, uncomment and run this query:
/*
SELECT DISTINCT 
    tb.primaryTitle, 
    tb.startYear, 
    tb.genres, 
    tb.titleType,
    tp.category as role
FROM name_basics nb
JOIN title_principals tp ON nb.nconst = tp.nconst
JOIN title_basics tb ON tp.tconst = tb.tconst
WHERE nb.primaryName ILIKE '%Chris Hemsworth%'
  AND tb.titleType IN ('movie', 'tvMovie')
ORDER BY tb.startYear DESC
LIMIT 20;
*/
