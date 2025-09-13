# IMDb Database Mapping Documentation

## Overview
This document describes the successful mapping and loading of IMDb database dump files into PostgreSQL. The database contains comprehensive movie and TV show information from IMDb.

## Database Schema

### Tables Successfully Loaded

| Table Name | Records Loaded | Description |
|------------|----------------|-------------|
| `name_basics` | 14,708,470 | People in the entertainment industry |
| `title_basics` | 11,905,456 | Movies, TV shows, and other titles |
| `title_ratings` | 1,612,856 | User ratings for titles |

### Table Structures

#### name_basics
Contains information about people in the entertainment industry.

```sql
CREATE TABLE name_basics (
    nconst TEXT PRIMARY KEY,           -- Unique identifier (e.g., nm0000001)
    primaryName TEXT,                  -- Name by which the person is most often credited
    birthYear TEXT,                    -- Birth year in YYYY format
    deathYear TEXT,                    -- Death year in YYYY format (NULL if alive)
    primaryProfession TEXT,            -- Top-3 professions (comma-separated)
    knownForTitles TEXT               -- Titles the person is known for (comma-separated)
);
```

#### title_basics  
Contains information about movies, TV shows, and other entertainment titles.

```sql
CREATE TABLE title_basics (
    tconst TEXT PRIMARY KEY,          -- Unique identifier (e.g., tt0000001)
    titleType TEXT,                   -- Type: movie, short, tvSeries, tvEpisode, etc.
    primaryTitle TEXT,                -- Popular title used by filmmakers
    originalTitle TEXT,               -- Original title in original language
    isAdult TEXT,                     -- 0: non-adult title, 1: adult title
    startYear TEXT,                   -- Release year (YYYY format)
    endYear TEXT,                     -- End year for TV Series (NULL for movies)
    runtimeMinutes TEXT,              -- Primary runtime in minutes
    genres TEXT                       -- Up to three genres (comma-separated)
);
```

#### title_ratings
Contains IMDb ratings and votes for titles.

```sql
CREATE TABLE title_ratings (
    tconst TEXT PRIMARY KEY,          -- Unique identifier (matches title_basics.tconst)
    averageRating FLOAT,              -- Weighted average of all individual ratings (1-10)
    numVotes INT                      -- Number of votes the title has received
);
```

## Data Loading Process

### Technical Implementation
- **CSV Parsing**: Used robust error handling with fallback from CSV format to text format
- **Character Encoding**: UTF-8 encoding for international characters
- **Error Handling**: Graceful handling of malformed CSV data with continuation on errors
- **Performance**: Optimized PostgreSQL settings for bulk data loading

### Data Loading Statistics
- **name_basics.tsv**: 864MB uncompressed, loaded successfully with text format
- **title_basics.tsv**: 982MB uncompressed, loaded successfully with text format  
- **title_ratings.tsv**: 27MB uncompressed, loaded successfully with CSV format

## Key Relationships

### Primary Relationships
- `name_basics.nconst` ↔ People identifiers (nm prefixed)
- `title_basics.tconst` ↔ Title identifiers (tt prefixed)
- `title_ratings.tconst` → `title_basics.tconst` (Foreign Key relationship)

### Data Connections
- People are connected to titles through `name_basics.knownForTitles`
- Ratings are linked to titles through `tconst` identifiers
- Title types include: movie, short, tvSeries, tvEpisode, tvMovie, tvSpecial, etc.

## Sample Queries

### Find Popular Movies
```sql
SELECT tb.primaryTitle, tb.startYear, tr.averageRating, tr.numVotes
FROM title_basics tb
JOIN title_ratings tr ON tb.tconst = tr.tconst
WHERE tb.titleType = 'movie' 
  AND tr.numVotes > 100000
ORDER BY tr.averageRating DESC, tr.numVotes DESC
LIMIT 10;
```

### Find Actor Information
```sql
SELECT primaryName, birthYear, deathYear, primaryProfession
FROM name_basics 
WHERE primaryName ILIKE '%hemsworth%'
  AND primaryProfession LIKE '%actor%';
```

### Movie Statistics by Year
```sql
SELECT startYear, COUNT(*) as movie_count, 
       AVG(tr.averageRating) as avg_rating
FROM title_basics tb
LEFT JOIN title_ratings tr ON tb.tconst = tr.tconst
WHERE tb.titleType = 'movie' 
  AND tb.startYear IS NOT NULL
  AND tb.startYear ~ '^[0-9]{4}$'
GROUP BY startYear
ORDER BY startYear DESC;
```

## Data Quality Notes

### Successful Fixes Applied
1. **CSV Parsing Errors**: Implemented fallback to text format for malformed quotes
2. **Missing Column Data**: Added error handling for incomplete rows
3. **Character Encoding**: Proper UTF-8 handling for international content
4. **Container Integration**: Proper volume mounting and file accessibility

### Data Characteristics
- Some fields contain `\N` representing NULL values
- Comma-separated values in `genres`, `primaryProfession`, and `knownForTitles`
- Years are stored as TEXT to handle special cases and ranges
- Adult content is flagged in `isAdult` field

## Performance Considerations

### Database Optimization
- Shared buffers: 512MB
- Work memory: 64MB  
- Maintenance work memory: 512MB
- Disabled fsync and synchronous_commit for bulk loading

### Indexing Recommendations
```sql
-- Recommended indexes for better query performance
CREATE INDEX idx_title_basics_titletype ON title_basics(titleType);
CREATE INDEX idx_title_basics_startyear ON title_basics(startYear);
CREATE INDEX idx_title_ratings_rating ON title_ratings(averageRating);
CREATE INDEX idx_name_basics_name ON name_basics(primaryName);
```

## File Sources
- **Data Source**: https://datasets.imdbws.com/
- **Update Frequency**: IMDb updates these files daily
- **File Format**: Tab-separated values (TSV) compressed with gzip

## Container Configuration
- **Database**: PostgreSQL 15
- **Container Name**: imdb_postgres
- **Port**: 5432
- **Volume Mounts**: 
  - `./data:/imdb_data` (data files)
  - `./init-scripts:/docker-entrypoint-initdb.d` (initialization scripts)
  - `./queries:/queries` (query files)
