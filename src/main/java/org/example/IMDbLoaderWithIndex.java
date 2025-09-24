package org.example;

import java.io.FileInputStream;
import java.io.IOException;
import java.sql.*;
import java.util.Properties;

public class IMDbLoaderWithIndex {

    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/imdb";
        Properties props = new Properties();
        props.setProperty("user", "postgres");
        props.setProperty("password", "yourpassword");

        try (Connection conn = DriverManager.getConnection(url, props)) {
            System.out.println("Connected to PostgreSQL!");

            // Load data into tables
            loadTable(conn, "name_basics", "E:/database/name.basics.tsv/name.basics.tsv");
            loadTable(conn, "title_basics", "E:/database/title.basics.tsv/title.basics.tsv");
            loadTable(conn, "title_ratings", "E:/database/title.ratings.tsv/title.ratings.tsv");
            loadTable(conn, "title_principals", "E:/database/title.principals.tsv/title.principals.tsv");

            // Create all necessary indexes
            createIndexes(conn);

            System.out.println("✅ Data load + indexes complete!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void loadTable(Connection conn, String tableName, String filePath) throws SQLException, IOException {
        System.out.println("Loading " + tableName + " from " + filePath);
        String copySQL = "COPY " + tableName + " FROM STDIN WITH (FORMAT CSV, DELIMITER E'\\t', HEADER true, NULL '\\N')";
        try (PreparedStatement stmt = conn.prepareStatement(copySQL);
             FileInputStream fis = new FileInputStream(filePath)) {
            org.postgresql.copy.CopyManager cm = new org.postgresql.copy.CopyManager((org.postgresql.core.BaseConnection) conn);
            cm.copyIn(copySQL, fis);
        }
    }

    private static void createIndexes(Connection conn) throws SQLException {
        String[] indexStatements = {
                // Enable trigram extension
                "CREATE EXTENSION IF NOT EXISTS pg_trgm",

                // Trigram index for faster name searches
                "CREATE INDEX IF NOT EXISTS idx_name_basics_primaryname_trgm " +
                        "ON name_basics USING gin (primaryname gin_trgm_ops)",

                // Speed up joins on nconst and tconst
                "CREATE INDEX IF NOT EXISTS idx_title_principals_nconst ON title_principals(nconst)",
                "CREATE INDEX IF NOT EXISTS idx_title_principals_tconst ON title_principals(tconst)",

                // Speed up joins on title_basics
                "CREATE INDEX IF NOT EXISTS idx_title_basics_tconst ON title_basics(tconst)",

                // Speed up lookups on ratings
                "CREATE INDEX IF NOT EXISTS idx_title_ratings_tconst ON title_ratings(tconst)",
                "CREATE INDEX IF NOT EXISTS idx_title_ratings_rating ON title_ratings(averagerating DESC)"
        };

        try (Statement stmt = conn.createStatement()) {
            for (String sql : indexStatements) {
                System.out.println("Running: " + sql);
                stmt.execute(sql);
            }
        }
    }
}
