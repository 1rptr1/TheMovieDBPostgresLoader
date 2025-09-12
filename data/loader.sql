-- SCHEMA DEFINITIONS
CREATE TABLE IF NOT EXISTS name_basics (
    nconst TEXT PRIMARY KEY,
    primaryName TEXT,
    birthYear TEXT,
    deathYear TEXT,
    primaryProfession TEXT,
    knownForTitles TEXT
);

CREATE TABLE IF NOT EXISTS title_basics (
    tconst TEXT PRIMARY KEY,
    titleType TEXT,
    primaryTitle TEXT,
    originalTitle TEXT,
    isAdult TEXT,
    startYear TEXT,
    endYear TEXT,
    runtimeMinutes TEXT,
    genres TEXT
);

CREATE TABLE IF NOT EXISTS title_akas (
    titleId TEXT,
    ordering INT,
    title TEXT,
    region TEXT,
    language TEXT,
    types TEXT,
    attributes TEXT,
    isOriginalTitle TEXT
);

CREATE TABLE IF NOT EXISTS title_crew (
    tconst TEXT PRIMARY KEY,
    directors TEXT,
    writers TEXT
);

CREATE TABLE IF NOT EXISTS title_episode (
    tconst TEXT PRIMARY KEY,
    parentTconst TEXT,
    seasonNumber TEXT,
    episodeNumber TEXT
);

CREATE TABLE IF NOT EXISTS title_principals (
    tconst TEXT,
    ordering INT,
    nconst TEXT,
    category TEXT,
    job TEXT,
    characters TEXT
);

CREATE TABLE IF NOT EXISTS title_ratings (
    tconst TEXT PRIMARY KEY,
    averageRating FLOAT,
    numVotes INT
);

-- LOAD DATA (COPY FROM IMDb TSVs)
COPY name_basics FROM '/imdb_data/name.basics.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
COPY title_basics FROM '/imdb_data/title.basics.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
COPY title_akas FROM '/imdb_data/title.akas.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
COPY title_crew FROM '/imdb_data/title.crew.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
COPY title_episode FROM '/imdb_data/title.episode.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
COPY title_principals FROM '/imdb_data/title.principals.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
COPY title_ratings FROM '/imdb_data/title.ratings.tsv' (FORMAT csv, DELIMITER E'\t', HEADER true);
