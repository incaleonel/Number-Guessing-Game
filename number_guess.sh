#!/bin/bash


PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( $RANDOM%1000 + 1 ))
echo $NUMBER lala
echo -e "\n~~~~ GUESSING NUMBER ~~~~"

echo "Enter your username:"
read USERNAME

USER=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")
GAMES_PLAYED=0

if [[ -z $USER ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS_NUM
NUMBER_OF_GUESSES=1
while [[ $GUESS_NUM != $NUMBER ]]
do 
  if [[ $GUESS_NUM =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS_NUM > $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
   (( NUMBER_OF_GUESSES++ ))
  else
    echo "That is not an integer, guess again:"
  fi
    read GUESS_NUM
done
(( GAMES_PLAYED++ ))

if [[ -z $USER ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME',$GAMES_PLAYED, $NUMBER_OF_GUESSES)")
else
  if [[ $NUMBER_OF_GUESSES < $BEST_GAME ]]
  then
    UPDATE_USER=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
  else
    UPDATE_USER=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
  fi
fi
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"