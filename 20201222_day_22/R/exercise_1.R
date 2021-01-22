# --- Day 22: Crab Combat ---
#   
# It only takes a few hours of sailing the ocean on a raft for boredom to sink 
# in. Fortunately, you brought a small deck of space cards! You'd like to play 
# a game of Combat, and there's even an opponent available: a small crab that 
# climbed aboard your raft before you left.
# 
# Fortunately, it doesn't take long to teach the crab the rules.
# 
# Before the game starts, split the cards so each player has their own deck 
# (your puzzle input). Then, the game consists of a series of rounds: both 
# players draw their top card, and the player with the higher-valued card wins 
# the round. The winner keeps both cards, placing them on the bottom of their 
# own deck so that the winner's card is above the other card. If this causes a 
# player to have all of the cards, they win, and the game ends.
# 
# For example, consider the following starting decks:
#   
# Player 1:
# 9
# 2
# 6
# 3
# 1
# 
# Player 2:
# 5
# 8
# 4
# 7
# 10
# 
# This arrangement means that player 1's deck contains 5 cards, with 9 on top 
# and 1 on the bottom; player 2's deck also contains 5 cards, with 5 on top 
# and 10 on the bottom.
# 
# The first round begins with both players drawing the top card of their 
# decks: 9 and 5. Player 1 has the higher card, so both cards move to the 
# bottom of player 1's deck such that 9 is above 5. In total, it takes 29 
# rounds before a player has all of the cards:
# 
# -- Round 1 --
# Player 1's deck: 9, 2, 6, 3, 1
# Player 2's deck: 5, 8, 4, 7, 10
# Player 1 plays: 9
# Player 2 plays: 5
# Player 1 wins the round!
# 
# -- Round 2 --
# Player 1's deck: 2, 6, 3, 1, 9, 5
# Player 2's deck: 8, 4, 7, 10
# Player 1 plays: 2
# Player 2 plays: 8
# Player 2 wins the round!
# 
# -- Round 3 --
# Player 1's deck: 6, 3, 1, 9, 5
# Player 2's deck: 4, 7, 10, 8, 2
# Player 1 plays: 6
# Player 2 plays: 4
# Player 1 wins the round!
# 
# -- Round 4 --
# Player 1's deck: 3, 1, 9, 5, 6, 4
# Player 2's deck: 7, 10, 8, 2
# Player 1 plays: 3
# Player 2 plays: 7
# Player 2 wins the round!
# 
# -- Round 5 --
# Player 1's deck: 1, 9, 5, 6, 4
# Player 2's deck: 10, 8, 2, 7, 3
# Player 1 plays: 1
# Player 2 plays: 10
# Player 2 wins the round!
# 
# ...several more rounds pass...
# 
# -- Round 27 --
# Player 1's deck: 5, 4, 1
# Player 2's deck: 8, 9, 7, 3, 2, 10, 6
# Player 1 plays: 5
# Player 2 plays: 8
# Player 2 wins the round!
# 
# -- Round 28 --
# Player 1's deck: 4, 1
# Player 2's deck: 9, 7, 3, 2, 10, 6, 8, 5
# Player 1 plays: 4
# Player 2 plays: 9
# Player 2 wins the round!
# 
# -- Round 29 --
# Player 1's deck: 1
# Player 2's deck: 7, 3, 2, 10, 6, 8, 5, 9, 4
# Player 1 plays: 1
# Player 2 plays: 7
# Player 2 wins the round!
# 
# 
# == Post-game results ==
# Player 1's deck: 
# Player 2's deck: 3, 2, 10, 6, 8, 5, 9, 4, 7, 1
# 
# Once the game ends, you can calculate the winning player's score. The bottom 
# card in their deck is worth the value of the card multiplied by 1, the 
# second-from-the-bottom card is worth the value of the card multiplied by 2, 
# and so on. With 10 cards, the top card is worth the value on the card 
# multiplied by 10. In this example, the winning player's score is:
# 
#    3 * 10
# +  2 *  9
# + 10 *  8
# +  6 *  7
# +  8 *  6
# +  5 *  5
# +  9 *  4
# +  4 *  3
# +  7 *  2
# +  1 *  1
# = 306
# 
# So, once the game ends, the winning player's score is 306.
# 
# Play the small crab in a game of Combat using the two decks you just dealt. 
# What is the winning player's score?

# Setup ------------------------------------------------------------------------

test_input <- c(
  "Player 1:",
  "9", "2", "6", "3", "1",
  "",
  "Player 2:",
  "5", "8", "4", "7", "10"
)
real_input <- readLines('../input.txt')

library(dequer)


# Functions --------------------------------------------------------------------

# Helper function, given a vector of input lines returns an environment
# containing both player's (player1 and player2) decks and a starting number
# for the number of rounds the game has progressed
parse_input <- function(input) {
  hands <- list(
    player1 = queue(),  # A queue for handling player 1's deck
    player2 = queue(),  # A queue for handling player 2's deck
    round = 1           # Start with round == 1
  )
  
  # Starting from scratch, for every line in the input
  current_player <- ''
  for (line in input) {
    if (line == '') { next }  # Skip blank lines
    
    # If the line indicates a player, set `current_player` to a string
    # indicating that player's name. Otherwise, add the number on the line
    # to `current_player`'s deck.
    if (grepl('Player', line)) { 
      current_player <- tolower(gsub('[ :]', '', line)) 
    } else {
      pushback(hands[[current_player]], as.numeric(line))
    }
  }
  list2env(hands, new.env())  # Return an environment
}

# Purely for debugging purposes, prints important bits from the game state
# to the console
pprint <- function(game_state) {
  cat('\n\n')
  cat('-- Round ', game_state$round, ' --', '\n')
  cat(
    'Player 1 deck:  ', 
    game_state$p1_card, ', ', 
    paste(unlist(as.list(game_state$player1)), collapse = ', '), 
    '\n',
    sep = ''
  )
  cat(
    'Player 2 deck:  ', 
    game_state$p2_card, ', ', 
    paste(unlist(as.list(game_state$player2)), collapse = ', '), 
    '\n',
    sep = ''
  )
  cat('Player 1 plays:', game_state$p1_card, '\n')
  cat('Player 2 plays:', game_state$p2_card, '\n')
  cat('Winner: ', game_state$winner, '\n')
}

# Given an environment `env` representing the game state, updates the game 
# state by simulating a round of play and returns the game state.
next_state <- function(env) {
  # Both players draw. It's not strictly necessary to include the player's
  # cards or the name of the player who won the round in the environment,
  # but it helps with debugging
  env$p1_card <- pop(env$player1)
  env$p2_card <- pop(env$player2)
  
  # pprint(env)  # Prints important bits of the game state to console
  
  # Identify the winner and add the cards to the winner's deck
  env$winner <- if (env$p1_card > env$p2_card) { 'player1' } else { 'player2' }
  if (env$winner == 'player1') {
    pushback(env$player1, env$p1_card)
    pushback(env$player1, env$p2_card)
  } else {
    pushback(env$player2, env$p2_card)
    pushback(env$player2, env$p1_card)
  }
  
  env$round <- env$round + 1  # Advance the round count
  
  # If a player's deck is empty, the other player won the game. Add the winning
  # player's current deck to the environment `env`
  if (length(env$player1) == 0) { env$winner_deck <- unlist(as.list(env$player2)) }
  if (length(env$player2) == 0) { env$winner_deck <- unlist(as.list(env$player1)) }
  
  env  # Return the modified environment
}


# Processing -------------------------------------------------------------------

game_state <- parse_input(real_input)  # Parse the input

# Until a player wins, advance the game state to the next state
while (is.null(game_state$winner_deck)) { game_state <- next_state(game_state) }
cards_in_winner_deck <- length(game_state$winner_deck)
answer1 <- sum(game_state$winner_deck * cards_in_winner_deck:1)

# Answer: 33772
