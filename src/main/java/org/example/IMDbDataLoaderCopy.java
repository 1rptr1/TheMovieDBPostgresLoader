package org.example;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class IMDbDataLoaderCopy {

    // Update these for your local setup
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/imdb";
    private static final String USER = "postgres";
    private static final String PASSWORD = "password";

    public static void main(String[] args) {
        try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASSWORD)) {
            System.out.println("Connected to PostgreSQL!");

            createTables(conn); // Step 1: Create schema
            loadAllTables(conn); // Step 2: Load files via COPY
            createIndexes(conn); // Step 3: Create indexes

            System.out.println("✅ All data loaded successfully!");
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

    private static void loadAllTables(Connection conn) throws SQLException {
        copyFile(conn, "E:/database/name.basics.tsv/name.basics.tsv", "name_basics");
        copyFile(conn, "E:/database/title.basics.tsv/title.basics.tsv", "title_basics");
        copyFile(conn, "E:/database/title.akas.tsv/title.akas.tsv", "title_akas");
        copyFile(conn, "E:/database/title.crew.tsv/title.crew.tsv", "title_crew");
        copyFile(conn, "E:/database/title.episode.tsv/title.episode.tsv", "title_episode");
        copyFile(conn, "E:/database/title.principals.tsv/title.principals.tsv", "title_principals");
        copyFile(conn, "E:/database/title.ratings.tsv/title.ratings.tsv", "title_ratings");
    }

    private static void copyFile(Connection conn, String filePath, String tableName) throws SQLException {
        String sql = "COPY " + tableName + " FROM '" + filePath.replace("\\", "/") +
                "' (FORMAT text, DELIMITER E'\\t', HEADER true, NULL '\\N')";
        try (Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
            System.out.println("✅ Loaded table " + tableName + " via COPY from " + filePath);
        }
    }


    private static void createIndexes(Connection conn) throws SQLException {
        String indexSQL = """
                    CREATE INDEX IF NOT EXISTS idx_name_basics_primaryName ON name_basics (primaryName);
                    CREATE INDEX IF NOT EXISTS idx_title_basics_primaryTitle ON title_basics (primaryTitle);
                    CREATE INDEX IF NOT EXISTS idx_title_ratings_averageRating ON title_ratings (averageRating);
                """;
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(indexSQL);
            System.out.println("✅ Indexes created.");
        }
    }
}
