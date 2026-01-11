#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"
#Get number
number=$((1 + RANDOM % 1000))
score=1
#Ask for username
echo Enter your username:
read name
#Existence check
check=$($PSQL "SELECT username FROM users WHERE username='$name';")
if [[ -z $check ]]
then
  play_count=1
  best=1
  echo "Welcome, $name! It looks like this is your first time here."
else
  play_count=$($PSQL "SELECT games_played FROM users WHERE username='$name';")
  best=$($PSQL "SELECT best_game FROM users WHERE username='$name';")
  echo "Welcome back, $name! You have played $play_count games, and your best game took $best guesses."
fi
echo "Guess the secret number between 1 and 1000:"
#Main loop
while [[ $guess != $number ]]
do
  read guess
  if ! [[ "$guess" =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    ((score++))
  elif [[ $guess -gt $number ]]
  then
    echo "It's lower than that, guess again:"
    ((score++))
  elif [[ $guess -lt $number ]]
  then
    echo "It's higher than that, guess again:"
    ((score++))
  elif [[ $guess == $number ]]
  then
    echo "You guessed it in $score tries. The secret number was $number. Nice job!"
  fi
done
#Insert into datbase
##If first time
if [[ -z $check ]]
then
  insert=$($PSQL "INSERT INTO users(username,best_game,games_played) VALUES ('$name',$score,$play_count);")
##If not first time
else
  if [[ $score -lt $best ]]
  then
    insert=$($PSQL "INSERT INTO users(username,best_game,games_played) VALUES ('$name',$score,$play_count);")
  elif [[ $score -ge $best ]]
  then
    echo not reached 
    insert=$($PSQL "INSERT INTO users(username,best_game,games_played) VALUES ('$name',$best,$play_count);")
  fi
fi