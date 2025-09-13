-- LOAD DATA INTO TABLES
-- Run this manually after container is running:
-- docker exec -i imdb_postgres psql -U imdb -d imdb -f /queries/load_data_manual.sql

COPY name_basics FROM '/imdb_data/name.basics.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
COPY title_basics FROM '/imdb_data/title.basics.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
COPY title_akas FROM '/imdb_data/title.akas.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
COPY title_crew FROM '/imdb_data/title.crew.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
COPY title_episode FROM '/imdb_data/title.episode.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
COPY title_principals FROM '/imdb_data/title.principals.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
COPY title_ratings FROM '/imdb_data/title.ratings.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
