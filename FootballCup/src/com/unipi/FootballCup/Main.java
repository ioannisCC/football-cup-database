package com.unipi.FootballCup;

import java.nio.charset.StandardCharsets;
import java.sql.*;

public class Main {

    public static void main(String[] args) {
        try {
            Connection connection = DriverManager.getConnection("jdbc:postgresql://localhost:5432/FootballCup", "postgres", "alexhs123");
            Statement statement = connection.createStatement();

            // Selection 2.a
            String query2a = "SELECT club.name_cl, coach.name, coach.surname " +
                    "FROM match_and_schedule " +
                    "JOIN club ON (match_and_schedule.home_club = club.name_cl OR match_and_schedule.visiting_club = club.name_cl) " +
                    "JOIN coach ON (club.name_cl = coach.name_cl AND coach.is_coach = true) " +
                    "WHERE match_and_schedule.id_ms = 10 AND club.name_cl = 'Olympiacos' AND coach.is_coach = true";
            ResultSet resultSet2a = statement.executeQuery(query2a);

            System.out.println("Selection 2.a: Club name, coach name, and coach surname");
            // Process the results
            while (resultSet2a.next()) {
                String clubName = resultSet2a.getString("name_cl");
                String coachName = resultSet2a.getString("name");
                String coachSurname = resultSet2a.getString("surname");
                System.out.println("Club: " + clubName);
                System.out.println("Coach: " + coachName + " " + coachSurname);
            }

            resultSet2a.close();
            System.out.println();

            // Selection 2.b
            String query2b = "SELECT match_and_player_goals.penalty, match_and_player_goals.goals_s, match_and_player_goals.time, player.name, player.surname " +
                    "FROM match_and_schedule " +
                    "JOIN match_and_player_goals ON match_and_player_goals.id_ms = match_and_schedule.id_ms " +
                    "JOIN player ON player.id_p = match_and_player_goals.id_player " +
                    "WHERE match_and_schedule.id_ms = 10";
            ResultSet resultSet2b = statement.executeQuery(query2b);

            System.out.println("Selection 2.b: Penalty, goals scored, time, player name, and player surname");
            // Process the results
            while (resultSet2b.next()) {
                boolean penalty = resultSet2b.getBoolean("penalty");
                boolean goalsScored = resultSet2b.getBoolean("goals_s");
                Time time = resultSet2b.getTime("time");
                String playerName = resultSet2b.getString("name");
                String playerSurname = resultSet2b.getString("surname");
                System.out.println("Penalty: " + penalty);
                System.out.println("Goals Scored: " + goalsScored);
                System.out.println("Time: " + time);
                System.out.println("Player Name: " + playerName);
                System.out.println("Player Surname: " + playerSurname);
                System.out.println("===============================");
            }

            resultSet2b.close();
            System.out.println();

            // Selection 2.c
            String query2c = "SELECT player.id_p, player.name, player.surname, SUM(match_and_player_time_played.time_played) AS total_time_played, player.position, " +
                    "COALESCE(SUM(CASE WHEN match_and_player_goals.goals_s = true THEN 1 ELSE 0 END), 0) AS player_goals, " +
                    "COALESCE(SUM(CASE WHEN match_and_player_goals.penalty = true THEN 1 ELSE 0 END), 0) AS player_penalties, " +
                    "COALESCE(SUM(CASE WHEN match_and_player_cards.cards_y = true THEN 1 ELSE 0 END), 0) AS player_yellow_cards, " +
                    "COALESCE(SUM(CASE WHEN match_and_player_cards.cards_r = true THEN 1 ELSE 0 END), 0) AS player_red_cards " +
                    "FROM match_and_schedule " +
                    "NATURAL JOIN match_and_player_time_played " +
                    "JOIN player ON player.id_p = match_and_player_time_played.id_player " +
                    "NATURAL JOIN match_and_player_goals " +
                    "LEFT JOIN match_and_player_cards ON match_and_player_cards.id_player = match_and_player_goals.id_player " +
                    "WHERE (match_and_schedule.date BETWEEN '2023-04-01' AND '2023-06-30') AND match_and_player_time_played.id_player = 14 " +
                    "GROUP BY player.id_p";
            ResultSet resultSet2c = statement.executeQuery(query2c);

            System.out.println("Selection 2.c: Player statistics");
            // Process the results
            while (resultSet2c.next()) {
                int playerId = resultSet2c.getInt("id_p");
                String playerName = resultSet2c.getString("name");
                String playerSurname = resultSet2c.getString("surname");
                Time totalPlayedTime = resultSet2c.getTime("total_time_played");
                String position = resultSet2c.getString("position");
                int playerGoals = resultSet2c.getInt("player_goals");
                int playerPenalties = resultSet2c.getInt("player_penalties");
                int playerYellowCards = resultSet2c.getInt("player_yellow_cards");
                int playerRedCards = resultSet2c.getInt("player_red_cards");

                System.out.println("Player ID: " + playerId);
                System.out.println("Player Name: " + playerName);
                System.out.println("Player Surname: " + playerSurname);
                System.out.println("Total Played Time: " + totalPlayedTime);
                System.out.println("Position: " + position);
                System.out.println("Player Goals: " + playerGoals);
                System.out.println("Player Penalties: " + playerPenalties);
                System.out.println("Player Yellow Cards: " + playerYellowCards);
                System.out.println("Player Red Cards: " + playerRedCards);
            }

            resultSet2c.close();
            System.out.println();

            // Selection 2.d
            String query2d = "SELECT " +
                    "home_matches, " +
                    "away_matches, " +
                    "total_home_score, " +
                    "total_away_score, " +
                    "total_home_score + total_away_score AS total_score, " +
                    "home_matches + away_matches AS total_matches, " +
                    "subquery.total_wins_home, " +
                    "subquery.total_wins_away, " +
                    "subquery.total_wins_home + subquery.total_wins_away AS total_wins, " +
                    "subquery.total_draws_home, " +
                    "subquery.total_draws_away, " +
                    "subquery.total_draws_home + subquery.total_draws_away AS total_draws, " +
                    "(home_matches + away_matches) - (subquery.total_wins_home + subquery.total_wins_away + subquery.total_draws_home + subquery.total_draws_away) AS total_losses, " +
                    "home_matches - (subquery.total_wins_home + subquery.total_draws_home) AS total_losses_home, " +
                    "away_matches - (subquery.total_wins_away + subquery.total_draws_away) AS total_losses_away " +
                    "FROM ( " +
                    "SELECT " +
                    "SUM(CASE WHEN match_and_schedule.home_club='Aek' THEN 1 ELSE 0 END) AS home_matches, " +
                    "SUM(CASE WHEN match_and_schedule.visiting_club='Aek' THEN 1 ELSE 0 END) AS away_matches, " +
                    "SUM(CASE WHEN match_and_schedule.home_club='Aek' THEN match_and_schedule.home_score ELSE 0 END) AS total_home_score, " +
                    "SUM(CASE WHEN match_and_schedule.visiting_club='Aek' THEN match_and_schedule.visiting_score ELSE 0 END) AS total_away_score, " +
                    "SUM(CASE WHEN (match_and_schedule.home_club='Aek' AND (match_and_schedule.home_score > match_and_schedule.visiting_score)) THEN 1 ELSE 0 END) AS total_wins_home, " +
                    "SUM(CASE WHEN (match_and_schedule.visiting_club='Aek' AND (match_and_schedule.visiting_score > match_and_schedule.home_score)) THEN 1 ELSE 0 END) AS total_wins_away, " +
                    "SUM(CASE WHEN (match_and_schedule.home_club='Aek' AND (match_and_schedule.home_score = match_and_schedule.visiting_score)) THEN 1 ELSE 0 END) AS total_draws_home, " +
                    "SUM(CASE WHEN (match_and_schedule.visiting_club='Aek' AND (match_and_schedule.visiting_score = match_and_schedule.home_score)) THEN 1 ELSE 0 END) AS total_draws_away " +
                    "FROM match_and_schedule " +
                    "WHERE match_and_schedule.date BETWEEN '2023-04-01' AND '2023-06-30' " +
                    ") AS subquery";
            ResultSet resultSet2d = statement.executeQuery(query2d);

            System.out.println("Selection 2.d: Team statistics");
            // Process the results
            while (resultSet2d.next()) {
                int homeMatches = resultSet2d.getInt("home_matches");
                int awayMatches = resultSet2d.getInt("away_matches");
                int totalHomeScore = resultSet2d.getInt("total_home_score");
                int totalAwayScore = resultSet2d.getInt("total_away_score");
                int totalScore = resultSet2d.getInt("total_score");
                int totalMatches = resultSet2d.getInt("total_matches");
                int totalWinsHome = resultSet2d.getInt("total_wins_home");
                int totalWinsAway = resultSet2d.getInt("total_wins_away");
                int totalWins = resultSet2d.getInt("total_wins");
                int totalDrawsHome = resultSet2d.getInt("total_draws_home");
                int totalDrawsAway = resultSet2d.getInt("total_draws_away");
                int totalDraws = resultSet2d.getInt("total_draws");
                int totalLosses = resultSet2d.getInt("total_losses");
                int totalLossesHome = resultSet2d.getInt("total_losses_home");
                int totalLossesAway = resultSet2d.getInt("total_losses_away");

                System.out.println("Home Matches: " + homeMatches);
                System.out.println("Away Matches: " + awayMatches);
                System.out.println("Total Home Score: " + totalHomeScore);
                System.out.println("Total Away Score: " + totalAwayScore);
                System.out.println("Total Score: " + totalScore);
                System.out.println("Total Matches: " + totalMatches);
                System.out.println("Total Wins (Home): " + totalWinsHome);
                System.out.println("Total Wins (Away): " + totalWinsAway);
                System.out.println("Total Wins: " + totalWins);
                System.out.println("Total Draws (Home): " + totalDrawsHome);
                System.out.println("Total Draws (Away): " + totalDrawsAway);
                System.out.println("Total Draws: " + totalDraws);
                System.out.println("Total Losses: " + totalLosses);
                System.out.println("Total Losses (Home): " + totalLossesHome);
                System.out.println("Total Losses (Away): " + totalLossesAway);
            }

            resultSet2d.close();

            statement.close();
            connection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
