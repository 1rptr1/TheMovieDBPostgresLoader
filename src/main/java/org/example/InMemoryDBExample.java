package org.example;

import java.sql.*;

public class InMemoryDBExample {
    public static void main(String[] args) {
        String url = "jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1"; // in-memory
        String user = "sa";
        String password = "";

        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement stmt = conn.createStatement()) {

            // 1. Create table
            stmt.execute("CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(100))");

            // 2. Insert some rows
            stmt.execute("INSERT INTO users VALUES (1, 'Alice')");
            stmt.execute("INSERT INTO users VALUES (2, 'Bob')");

            // 3. Query
            try (ResultSet rs = stmt.executeQuery("SELECT * FROM users")) {
                while (rs.next()) {
                    System.out.println(rs.getInt("id") + " -> " + rs.getString("name"));
                }
            }

            // 4. Export to SQL file (optional)
            stmt.execute("SCRIPT TO 'backup.sql'");

            // 5. Drop table (not needed if you want auto-drop on JVM exit)
            stmt.execute("DROP TABLE users");
        } catch (Exception e) {
            e.printStackTrace();
        }
        // when JVM exits, DB is wiped automatically
    }
}
