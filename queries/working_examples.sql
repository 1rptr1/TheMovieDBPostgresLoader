-- Working Example Queries for IMDb Database
-- These queries work with the currently loaded data

-- 1. Check data availability across all tables
SELECT 
    'name_basics' as table_name, COUNT(*) as row_count FROM name_basics
UNION ALL
SELECT 'title_basics', COUNT(*) FROM title_basics
UNION ALL
SELECT 'title_ratings', COUNT(*) FROM title_ratings
UNION ALL
SELECT 'title_principals', COUNT(*) FROM title_principals
UNION ALL
SELECT 'title_akas', COUNT(*) FROM title_akas
UNION ALL
SELECT 'title_crew', COUNT(*) FROM title_crew
UNION ALL
SELECT 'title_episode', COUNT(*) FROM title_episode
ORDER BY row_count DESC;

-- 2. Chris Hemsworth Information (Works with current data)
SELECT 
    nconst, 
    primaryName, 
    birthYear, 
    primaryProfession, 
    knownForTitles
FROM name_basics 
WHERE primaryName ILIKE '%Chris Hemsworth%';

-- 3. Top 10 Most Popular Actors by Birth Year (Works with current data)
SELECT 
    primaryName,
    birthYear,
    primaryProfession,
    CASE 
        WHEN knownForTitles IS NOT NULL AND knownForTitles != '\N' 
        THEN array_length(string_to_array(knownForTitles, ','), 1)
        ELSE 0 
    END as known_titles_count
FROM name_basics 
WHERE primaryProfession LIKE '%actor%' 
    AND birthYear IS NOT NULL 
    AND birthYear != '\N'
    AND birthYear::int BETWEEN 1970 AND 1990
ORDER BY known_titles_count DESC, primaryName
LIMIT 10;

-- 4. Top Rated Movies (Works with title_ratings data)
SELECT 
    tr.tconst,
    tr.averageRating,
    tr.numVotes
FROM title_ratings tr
WHERE tr.numVotes >= 100000  -- Movies with significant vote count
ORDER BY tr.averageRating DESC, tr.numVotes DESC
LIMIT 20;

-- 5. Find actors born in specific year (Works with current data)
SELECT 
    primaryName,
    primaryProfession,
    knownForTitles
FROM name_basics 
WHERE birthYear = '1983'  -- Same year as Chris Hemsworth
    AND primaryProfession LIKE '%actor%'
ORDER BY primaryName
LIMIT 15;

-- Note: Full movie queries require title_basics and title_principals data
-- These tables are empty in local development but populated in CI/production
