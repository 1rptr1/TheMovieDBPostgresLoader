package org.example;

import java.io.BufferedReader;
import java.io.FileReader;
import java.sql.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class IMDbDataLoader {

    private static final String DB_URL = "jdbc:postgresql://localhost:5432/imdb";
    private static final String USER = "postgres";
    private static final String PASSWORD = "password";

    public static void main(String[] args) {
        try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASSWORD)) {
            System.out.println("Connected to PostgreSQL!");

            createTables(conn);
            createIndexes(conn);

            // Executor for parallel loading
            ExecutorService executor = Executors.newFixedThreadPool(6);

            executor.submit(() -> loadTSV(conn, "E:/database/name.basics.tsv/name.basics.tsv",
                    "INSERT INTO name_basics VALUES (?, ?, ?, ?, ?, ?) ON CONFLICT DO NOTHING", 6));

            executor.submit(() -> loadTSV(conn, "E:/database/title.basics.tsv/title.basics.tsv",
                    "INSERT INTO title_basics VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO NOTHING", 9));

            executor.submit(() -> loadTSVInt(conn, "E:/database/title.akas.tsv/title.akas.tsv",
                    "INSERT INTO title_akas VALUES (?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO NOTHING", 8, 1));

            executor.submit(() -> loadTSV(conn, "E:/database/title.crew.tsv/title.crew.tsv",
                    "INSERT INTO title_crew VALUES (?, ?, ?) ON CONFLICT DO NOTHING", 3));

            executor.submit(() -> loadTSV(conn, "E:/database/title.episode.tsv/title.episode.tsv",
                    "INSERT INTO title_episode VALUES (?, ?, ?, ?) ON CONFLICT DO NOTHING", 4));

            executor.submit(() -> loadTSVInt(conn, "E:/database/title.principals.tsv/title.principals.tsv",
                    "INSERT INTO title_principals VALUES (?, ?, ?, ?, ?, ?) ON CONFLICT DO NOTHING", 6, 1));

            executor.submit(() -> loadTSVFloatInt(conn, "E:/database/title.ratings.tsv/title.ratings.tsv",
                    "INSERT INTO title_ratings VALUES (?, ?, ?) ON CONFLICT DO NOTHING", 3, 2, 3));

            executor.shutdown();
            while (!executor.isTerminated()) {
                Thread.sleep(500);
            }

            System.out.println("✅ All files loaded in parallel!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    private static void createTables(Connection conn) throws SQLException {
        String schema = """
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
                """;

        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(schema);
            System.out.println("✅ Tables created (if not exist).");
        }
    }

    private static void createIndexes(Connection conn) throws SQLException {
        String indexes = """
                    CREATE INDEX IF NOT EXISTS idx_name_basics_primaryName ON name_basics(primaryName);
                    CREATE INDEX IF NOT EXISTS idx_title_basics_primaryTitle ON title_basics(primaryTitle);
                    CREATE INDEX IF NOT EXISTS idx_title_akas_title ON title_akas(title);
                    CREATE INDEX IF NOT EXISTS idx_title_principals_nconst ON title_principals(nconst);
                """;

        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(indexes);
            System.out.println("✅ Indexes created.");
        }
    }

    private static void loadTSV(Connection conn, String filePath, String insertSQL, int columnCount) {
        System.out.println("📂 Loading file: " + filePath);
        try (BufferedReader br = new BufferedReader(new FileReader(filePath));
             PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {

            String line;
            boolean skipHeader = true;
            int batchSize = 5000;
            int count = 0;

            while ((line = br.readLine()) != null) {
                if (skipHeader) {
                    skipHeader = false;
                    continue;
                }
                String[] values = line.split("\t", -1);
                for (int i = 0; i < columnCount; i++) {
                    String val = i < values.length && !values[i].equals("\\N") ? values[i] : null;
                    pstmt.setString(i + 1, val);
                }

                pstmt.addBatch();
                if (++count % batchSize == 0) pstmt.executeBatch();
            }
            pstmt.executeBatch();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void loadTSVInt(Connection conn, String filePath, String insertSQL, int columnCount, int intColumnIndex) {
        System.out.println("📂 Loading file (int column): " + filePath);
        try (BufferedReader br = new BufferedReader(new FileReader(filePath));
             PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {

            String line;
            boolean skipHeader = true;
            int batchSize = 5000;
            int count = 0;

            while ((line = br.readLine()) != null) {
                if (skipHeader) {
                    skipHeader = false;
                    continue;
                }
                String[] values = line.split("\t", -1);
                for (int i = 0; i < columnCount; i++) {
                    if (i == intColumnIndex) {
                        try {
                            pstmt.setInt(i + 1, values[i].isEmpty() || values[i].equals("\\N") ? 0 : Integer.parseInt(values[i]));
                        } catch (NumberFormatException e) {
                            pstmt.setNull(i + 1, Types.INTEGER);
                        }
                    } else {
                        String val = i < values.length && !values[i].equals("\\N") ? values[i] : null;
                        pstmt.setString(i + 1, val);
                    }
                }
                pstmt.addBatch();
                if (++count % batchSize == 0) pstmt.executeBatch();
            }
            pstmt.executeBatch();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void loadTSVFloatInt(Connection conn, String filePath, String insertSQL, int columnCount, int floatIndex, int intIndex) {
        System.out.println("📂 Loading file (float/int columns): " + filePath);
        try (BufferedReader br = new BufferedReader(new FileReader(filePath));
             PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {

            String line;
            boolean skipHeader = true;
            int batchSize = 5000;
            int count = 0;

            while ((line = br.readLine()) != null) {
                if (skipHeader) {
                    skipHeader = false;
                    continue;
                }
                String[] values = line.split("\t", -1);

                for (int i = 0; i < columnCount; i++) {
                    if (i == floatIndex) {
                        try {
                            pstmt.setFloat(i + 1, Float.parseFloat(values[i]));
                        } catch (NumberFormatException e) {
                            pstmt.setNull(i + 1, Types.FLOAT);
                        }
                    } else if (i == intIndex) {
                        try {
                            pstmt.setInt(i + 1, Integer.parseInt(values[i]));
                        } catch (NumberFormatException e) {
                            pstmt.setNull(i + 1, Types.INTEGER);
                        }
                    } else {
                        String val = i < values.length && !values[i].equals("\\N") ? values[i] : null;
                        pstmt.setString(i + 1, val);
                    }
                }
                pstmt.addBatch();
                if (++count % batchSize == 0) pstmt.executeBatch();
            }
            pstmt.executeBatch();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
