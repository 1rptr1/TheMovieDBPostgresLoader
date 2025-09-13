-- Find all movies with Chris Hemsworth
-- Note: This query requires title_principals and title_basics data to be loaded

-- First, let's check if we have the required data
SELECT 
    'Data Status Check:' as info,
    (SELECT COUNT(*) FROM name_basics) as name_basics_count,
    (SELECT COUNT(*) FROM title_basics) as title_basics_count,
    (SELECT COUNT(*) FROM title_principals) as title_principals_count;

-- If title_principals and title_basics have data, run the full query:
SELECT DISTINCT tb.primaryTitle, tb.startYear, tb.genres
FROM name_basics nb
JOIN title_principals tp ON nb.nconst = tp.nconst
JOIN title_basics tb ON tp.tconst = tb.tconst
WHERE nb.primaryName ILIKE '%Chris Hemsworth%'
  AND tb.titleType IN ('movie', 'tvMovie')
ORDER BY tb.startYear DESC;

-- Alternative query if only name_basics is available:
-- SELECT nconst, primaryName, birthYear, primaryProfession, knownForTitles
-- FROM name_basics 
-- WHERE primaryName ILIKE '%Chris Hemsworth%';
