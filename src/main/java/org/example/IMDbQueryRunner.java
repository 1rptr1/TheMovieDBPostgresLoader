package org.example;

public class IMDbQueryRunner {
    public static void main(String[] args) {
        IMDbQueryService service = new IMDbQueryService();

        // Example calls
        service.getTopMoviesByActor("Shah Rukh Khan", 20);
        service.getTopMoviesByActor("Aamir Khan", 15);
    }
}
