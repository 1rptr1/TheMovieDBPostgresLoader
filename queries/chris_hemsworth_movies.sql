-- Find all movies with Chris Hemsworth

SELECT DISTINCT tb.primaryTitle, tb.startYear, tb.genres
FROM name_basics nb
JOIN title_principals tp ON nb.nconst = tp.nconst
JOIN title_basics tb ON tp.tconst = tb.tconst
WHERE nb.primaryName ILIKE '%Chris Hemsworth%'
ORDER BY tb.startYear;
