package org.example;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class IMDbQueryService {

    private static final String DB_URL = "jdbc:postgresql://localhost:5432/imdb";
    private static final String USER = "postgres";
    private static final String PASSWORD = "password";

    private static final String QUERY = """
                WITH actor AS (
                    SELECT nconst
                    FROM name_basics
                    WHERE primaryname ILIKE ?
                    LIMIT 1
                )
                SELECT tb.primarytitle, tr.averagerating
                FROM actor a
                JOIN title_principals tp ON tp.nconst = a.nconst
                JOIN title_basics tb ON tb.tconst = tp.tconst
                LEFT JOIN title_ratings tr ON tr.tconst = tb.tconst
                ORDER BY tr.averagerating DESC NULLS LAST
                LIMIT ?;
            """;

    public void getTopMoviesByActor(String actorName, int limit) {
        try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(QUERY)) {

            pstmt.setString(1, actorName);
            pstmt.setInt(2, limit);

            try (ResultSet rs = pstmt.executeQuery()) {
                System.out.println("Top " + limit + " movies for: " + actorName);
                while (rs.next()) {
                    String title = rs.getString("primarytitle");
                    double rating = rs.getDouble("averagerating");
                    System.out.printf("🎬 %s  ⭐ %.1f%n", title, rating);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
