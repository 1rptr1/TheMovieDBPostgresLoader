-- Manual IMDb data loading with three-tier error handling
-- This script handles CSV parsing errors gracefully

-- Load name_basics with error handling
DO $$
BEGIN
  -- Clear existing data first
  TRUNCATE TABLE name_basics;
  
  -- Tier 1: Try CSV format first
  BEGIN
    COPY name_basics FROM '/imdb_data/name.basics.tsv' 
    WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
    RAISE NOTICE 'Successfully loaded name_basics with CSV format';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'CSV format failed: %, trying text format...', SQLERRM;
    
    -- Tier 2: Try text format fallback
    BEGIN
      COPY name_basics FROM '/imdb_data/name.basics.tsv' 
      WITH (FORMAT text, DELIMITER E'\t', NULL '\N', ENCODING 'UTF8');
      RAISE NOTICE 'Successfully loaded name_basics with text format';
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Text format failed: %, trying manual parsing...', SQLERRM;
      
      -- Tier 3: Manual parsing with temporary table
      BEGIN
        CREATE TEMP TABLE temp_name_basics (raw_line TEXT);
        COPY temp_name_basics FROM '/imdb_data/name.basics.tsv' WITH (FORMAT text);
        
        INSERT INTO name_basics (nconst, primaryName, birthYear, deathYear, primaryProfession, knownForTitles)
        SELECT 
          CASE WHEN array_length(parts, 1) >= 1 THEN parts[1] ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 2 THEN parts[2] ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 3 AND parts[3] != '\N' THEN parts[3]::INTEGER ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 4 AND parts[4] != '\N' THEN parts[4]::INTEGER ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 5 THEN parts[5] ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 6 THEN parts[6] ELSE NULL END
        FROM (
          SELECT string_to_array(raw_line, E'\t') as parts 
          FROM temp_name_basics 
          WHERE raw_line NOT LIKE 'nconst%'
        ) t
        WHERE array_length(parts, 1) >= 2;
        
        DROP TABLE temp_name_basics;
        RAISE NOTICE 'Successfully loaded name_basics with manual parsing';
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Manual parsing failed: %', SQLERRM;
      END;
    END;
  END;
END
$$;

-- Load title_basics with error handling
DO $$
BEGIN
  -- Clear existing data first
  TRUNCATE TABLE title_basics;
  
  -- Tier 1: Try CSV format first
  BEGIN
    COPY title_basics FROM '/imdb_data/title.basics.tsv' 
    WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
    RAISE NOTICE 'Successfully loaded title_basics with CSV format';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'CSV format failed: %, trying text format...', SQLERRM;
    
    -- Tier 2: Try text format fallback
    BEGIN
      COPY title_basics FROM '/imdb_data/title.basics.tsv' 
      WITH (FORMAT text, DELIMITER E'\t', NULL '\N', ENCODING 'UTF8');
      RAISE NOTICE 'Successfully loaded title_basics with text format';
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Text format failed: %, trying manual parsing...', SQLERRM;
      
      -- Tier 3: Manual parsing with temporary table
      BEGIN
        CREATE TEMP TABLE temp_title_basics (raw_line TEXT);
        COPY temp_title_basics FROM '/imdb_data/title.basics.tsv' WITH (FORMAT text);
        
        INSERT INTO title_basics (tconst, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes, genres)
        SELECT 
          CASE WHEN array_length(parts, 1) >= 1 THEN parts[1] ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 2 THEN parts[2] ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 3 THEN parts[3] ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 4 THEN parts[4] ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 5 AND parts[5] != '\N' THEN parts[5]::INTEGER ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 6 AND parts[6] != '\N' THEN parts[6]::INTEGER ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 7 AND parts[7] != '\N' THEN parts[7]::INTEGER ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 8 AND parts[8] != '\N' THEN parts[8]::INTEGER ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 9 THEN parts[9] ELSE NULL END
        FROM (
          SELECT string_to_array(raw_line, E'\t') as parts 
          FROM temp_title_basics 
          WHERE raw_line NOT LIKE 'tconst%'
        ) t
        WHERE array_length(parts, 1) >= 4;
        
        DROP TABLE temp_title_basics;
        RAISE NOTICE 'Successfully loaded title_basics with manual parsing';
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Manual parsing failed: %', SQLERRM;
      END;
    END;
  END;
END
$$;

-- Load title_ratings (this one usually works fine)
DO $$
BEGIN
  -- Clear existing data first
  TRUNCATE TABLE title_ratings;
  
  BEGIN
    COPY title_ratings FROM '/imdb_data/title.ratings.tsv' 
    WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
    RAISE NOTICE 'Successfully loaded title_ratings';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Failed to load title_ratings: %', SQLERRM;
  END;
END
$$;

-- Show final counts
SELECT 'name_basics: ' || COUNT(*) || ' rows' FROM name_basics
UNION ALL
SELECT 'title_basics: ' || COUNT(*) || ' rows' FROM title_basics  
UNION ALL
SELECT 'title_ratings: ' || COUNT(*) || ' rows' FROM title_ratings;
