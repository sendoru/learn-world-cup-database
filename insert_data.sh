#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# init table
($PSQL "TRUNCATE TABLE games, teams")

# adding teams
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  # ignore first line
  if [[ $year = 'year' ]]
  then
    continue
  fi

  # add winner team in the teams table only if the team doesn't exist
  res=$($PSQL "SELECT name FROM teams WHERE name='$winner'")
  if [[ -z $res ]]
  then
    ($PSQL "INSERT INTO teams(name) values('$winner')")
  fi

  # add opponent team in the teams table only if the team doesn't exist
  res=$($PSQL "SELECT name FROM teams WHERE name='$opponent'")
  if [[ -z $res ]]
  then
    ($PSQL "INSERT INTO teams(name) values('$opponent')")
  fi
done

# adding games
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  # ignore first line
  if [[ $year = 'year' ]]
  then
    continue
  fi

  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
  ($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)")

done