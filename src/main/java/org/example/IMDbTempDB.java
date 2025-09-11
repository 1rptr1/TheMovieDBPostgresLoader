package org.example;

import java.io.*;
import java.sql.*;
import java.util.zip.GZIPInputStream;

public class IMDbTempDB {
    private static final String BASE_PATH = "C:/Users/saura/Downloads/";

    public static void main(String[] args) {
        String basePath = BASE_PATH;
        if (!basePath.endsWith("/") && !basePath.endsWith("\\")) {
            basePath += File.separator;
        }

        // IMDb dump files
        String[] files = {
                basePath + "name.basics.tsv.gz",
                basePath + "title.basics.tsv.gz",
                basePath + "title.akas.tsv.gz",
                basePath + "title.crew.tsv.gz",
                basePath + "title.episode.tsv.gz",
                basePath + "title.principals.tsv.gz",
                basePath + "title.ratings.tsv.gz"
        };

        String[] sqls = {
                "INSERT INTO names VALUES (?, ?, ?, ?, ?, ?)",
                "INSERT INTO titles VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                "INSERT INTO akas VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                "INSERT INTO crew VALUES (?, ?, ?)",
                "INSERT INTO episodes VALUES (?, ?, ?, ?)",
                "INSERT INTO principals VALUES (?, ?, ?, ?, ?, ?)",
                "INSERT INTO ratings VALUES (?, ?, ?)"
        };

        int[] cols = {6, 9, 8, 3, 4, 6, 3};

        String url = "jdbc:h2:mem:imdb;DB_CLOSE_DELAY=-1";

        try (Connection conn = DriverManager.getConnection(url, "sa", "")) {
            Class.forName("org.h2.Driver");
            Statement stmt = conn.createStatement();

            // Tables
            stmt.execute("CREATE TABLE names (nconst VARCHAR PRIMARY KEY, primaryName VARCHAR, birthYear VARCHAR, deathYear VARCHAR, primaryProfession VARCHAR, knownForTitles VARCHAR)");
            stmt.execute("CREATE TABLE titles (tconst VARCHAR PRIMARY KEY, titleType VARCHAR, primaryTitle VARCHAR, originalTitle VARCHAR, isAdult VARCHAR, startYear VARCHAR, endYear VARCHAR, runtimeMinutes VARCHAR, genres VARCHAR)");
            stmt.execute("CREATE TABLE akas (titleId VARCHAR, ordering VARCHAR, title VARCHAR, region VARCHAR, language VARCHAR, types VARCHAR, attributes VARCHAR, isOriginalTitle VARCHAR)");
            stmt.execute("CREATE TABLE crew (tconst VARCHAR, directors VARCHAR, writers VARCHAR)");
            stmt.execute("CREATE TABLE episodes (tconst VARCHAR, parentTconst VARCHAR, seasonNumber VARCHAR, episodeNumber VARCHAR)");
            stmt.execute("CREATE TABLE principals (tconst VARCHAR, ordering VARCHAR, nconst VARCHAR, category VARCHAR, job VARCHAR, characters VARCHAR)");
            stmt.execute("CREATE TABLE ratings (tconst VARCHAR, averageRating VARCHAR, numVotes VARCHAR)");

            // Load each file
            for (int i = 0; i < files.length; i++) {
                loadTSV(conn, files[i], sqls[i], cols[i]);
            }

            // ✅ Example query
            String actor = "Leonardo DiCaprio";
            String sql = """
                SELECT n.primaryName, t.primaryTitle, t.startYear, r.averageRating
                FROM names n
                JOIN principals p ON n.nconst = p.nconst
                JOIN titles t ON t.tconst = p.tconst
                LEFT JOIN ratings r ON t.tconst = r.tconst
                WHERE n.primaryName = ?
            """;
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, actor);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                System.out.println(rs.getString("primaryName") + " → " +
                        rs.getString("primaryTitle") + " (" +
                        rs.getString("startYear") + ") Rating: " +
                        rs.getString("averageRating"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Loader helper with progress
    static void loadTSV(Connection conn, String filePath, String insertSQL, int colCount) throws Exception {
        System.out.println("\nLoading: " + new File(filePath).getName() + " ...");
        long total = 0;

        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(new GZIPInputStream(new FileInputStream(filePath)), "UTF-8"));
             PreparedStatement ps = conn.prepareStatement(insertSQL)) {

            String line;
            boolean first = true;
            int batchSize = 0;

            while ((line = br.readLine()) != null) {
                if (first) { first = false; continue; } // skip header
                String[] cols = line.split("\t", -1);
                for (int i = 0; i < colCount; i++) {
                    ps.setString(i + 1, i < cols.length ? cols[i] : null);
                }
                ps.addBatch();
                batchSize++;
                total++;

                if (batchSize >= 5000) {
                    ps.executeBatch();
                    batchSize = 0;
                }

                if (total % 50000 == 0) {
                    System.out.println("   Inserted " + total + " rows...");
                }
            }
            ps.executeBatch();
        }

        System.out.println("Done ✅ " + new File(filePath).getName() + " (" + total + " rows)");
    }
}
