-- Find all movies with Chris Hemsworth
-- This query adapts based on available data

-- Data Status Check
SELECT 
    'Data Status Check:' as info,
    (SELECT COUNT(*) FROM name_basics) as name_basics_count,
    (SELECT COUNT(*) FROM title_basics) as title_basics_count,
    (SELECT COUNT(*) FROM title_principals) as title_principals_count;

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
    IF (SELECT COUNT(*) FROM title_basics) > 0 AND (SELECT COUNT(*) FROM title_principals) > 0 THEN
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
        RAISE NOTICE 'Full movie data not available. title_basics: %, title_principals: %', 
            (SELECT COUNT(*) FROM title_basics), 
            (SELECT COUNT(*) FROM title_principals);
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
