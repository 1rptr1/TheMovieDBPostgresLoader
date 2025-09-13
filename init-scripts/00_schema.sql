-- SCHEMA DEFINITIONS
-- This file only defines tables (no COPY commands here)
-- Data will be loaded manually via /queries/load_data_manual.sql

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
