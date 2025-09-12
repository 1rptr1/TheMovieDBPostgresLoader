CREATE TABLE IF NOT EXISTS title_episode (
    tconst TEXT PRIMARY KEY,
    parentTconst TEXT,
    seasonNumber TEXT,
    episodeNumber TEXT
);

COPY title_episode
FROM '/data/title.episode.tsv'
WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N');
