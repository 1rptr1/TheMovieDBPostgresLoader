SELECT DISTINCT tb.primarytitle AS movie_title,
       tb.startyear AS release_year,
       tr.averageRating,
       tr.numVotes
FROM name_basics nb
JOIN title_principals tp ON nb.nconst = tp.nconst
JOIN title_basics tb ON tp.tconst = tb.tconst
LEFT JOIN title_ratings tr ON tb.tconst = tr.tconst
WHERE nb.primaryname ILIKE 'Chris Hemsworth'
  AND tb.titletype = 'movie'
ORDER BY tb.startyear;


