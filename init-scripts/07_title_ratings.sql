CREATE TABLE IF NOT EXISTS title_ratings (
    tconst TEXT PRIMARY KEY,
    averageRating FLOAT,
    numVotes INT
);

COPY title_ratings
FROM '/imdb_data/title.ratings.tsv'
WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
