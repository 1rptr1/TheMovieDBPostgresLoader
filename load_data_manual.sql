-- Manual IMDb data loading with optimized error handling
-- This script handles CSV parsing errors gracefully by using text format first

-- Load name_basics with error handling (handles unterminated CSV quoted fields)
DO $$
BEGIN
  -- Clear existing data first
  TRUNCATE TABLE name_basics;
  
  -- Check if file exists first
  BEGIN
    -- Try text format first to bypass CSV parsing issues with quotes
    BEGIN
      COPY name_basics FROM '/imdb_data/name.basics.tsv' 
      WITH (FORMAT text, DELIMITER E'\t', NULL '\N', ENCODING 'UTF8');
      RAISE NOTICE 'Successfully loaded name_basics with text format';
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Text format failed: %, trying manual parsing...', SQLERRM;
      
      -- Fallback to manual parsing with temporary table
      BEGIN
        CREATE TEMP TABLE temp_name_basics (raw_line TEXT);
        COPY temp_name_basics FROM '/imdb_data/name.basics.tsv' WITH (FORMAT text);
        
        INSERT INTO name_basics (nconst, primaryName, birthYear, deathYear, primaryProfession, knownForTitles)
        SELECT 
          parts[1],
          parts[2],
          CASE WHEN parts[3] != '\N' THEN parts[3]::INTEGER ELSE NULL END,
          CASE WHEN parts[4] != '\N' THEN parts[4]::INTEGER ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 5 THEN parts[5] ELSE NULL END,
          CASE WHEN array_length(parts, 1) >= 6 THEN parts[6] ELSE NULL END
        FROM (
          SELECT string_to_array(raw_line, E'\t') as parts 
          FROM temp_name_basics 
          WHERE raw_line NOT LIKE 'nconst%'
        ) t
        WHERE array_length(parts, 1) >= 4;
        
        DROP TABLE temp_name_basics;
        RAISE NOTICE 'Successfully loaded name_basics with manual parsing';
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Manual parsing failed: %', SQLERRM;
      END;
    END;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'File not found or accessible: %', SQLERRM;
  END;
END
$$;

-- Load title_basics with error handling (handles missing column data)
DO $$
BEGIN
  -- Clear existing data first
  TRUNCATE TABLE title_basics;
  
  -- Check if file exists first
  BEGIN
    -- Try text format first to bypass CSV parsing issues with missing columns
    BEGIN
      COPY title_basics FROM '/imdb_data/title.basics.tsv' 
      WITH (FORMAT text, DELIMITER E'\t', NULL '\N', ENCODING 'UTF8');
      RAISE NOTICE 'Successfully loaded title_basics with text format';
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Text format failed: %, trying manual parsing...', SQLERRM;
      
      -- Fallback to manual parsing with flexible column handling
      BEGIN
        CREATE TEMP TABLE temp_title_basics (raw_line TEXT);
        COPY temp_title_basics FROM '/imdb_data/title.basics.tsv' WITH (FORMAT text);
        
        INSERT INTO title_basics (tconst, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes, genres)
        SELECT 
          parts[1],
          parts[2],
          parts[3],
          parts[4],
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
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'File not found or accessible: %', SQLERRM;
  END;
END
$$;

-- Load title_ratings (usually works with CSV format)
DO $$
BEGIN
  -- Clear existing data first
  TRUNCATE TABLE title_ratings;
  
  BEGIN
    -- Try CSV format first (this usually works for title_ratings)
    COPY title_ratings FROM '/imdb_data/title.ratings.tsv' 
    WITH (FORMAT CSV, DELIMITER E'\t', HEADER true, NULL '\N', ENCODING 'UTF8');
    RAISE NOTICE 'Successfully loaded title_ratings with CSV format';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'CSV format failed: %, trying text format...', SQLERRM;
    
    -- Fallback to text format
    BEGIN
      COPY title_ratings FROM '/imdb_data/title.ratings.tsv' 
      WITH (FORMAT text, DELIMITER E'\t', NULL '\N', ENCODING 'UTF8');
      RAISE NOTICE 'Successfully loaded title_ratings with text format';
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Failed to load title_ratings: %', SQLERRM;
    END;
  END;
END
$$;

-- Show final counts
SELECT 'name_basics: ' || COUNT(*) || ' rows' FROM name_basics
UNION ALL
SELECT 'title_basics: ' || COUNT(*) || ' rows' FROM title_basics  
UNION ALL
SELECT 'title_ratings: ' || COUNT(*) || ' rows' FROM title_ratings;
