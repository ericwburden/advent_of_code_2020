#' **--- Day 15: Rambunctious Recitation ---**
#'   
#' You catch the airport shuttle and try to book a new flight to your vacation 
#' island. Due to the storm, all direct flights have been canceled, but a 
#' route is available to get around the storm. You take it.
#' 
#' While you wait for your flight, you decide to check in with the Elves back 
#' at the North Pole. They're playing a memory game and are ever so excited to 
#' explain the rules!
#' 
#' In this game, the players take turns saying numbers. They begin by taking 
#' turns reading from a list of starting numbers (your puzzle input). Then, 
#' each turn consists of considering the most recently spoken number:
#' 
#'     - If that was the first time the number has been spoken, the current 
#'       player says 0.
#'     - Otherwise, the number had been spoken before; the current player 
#'       announces how many turns apart the number is from when it was 
#'       previously spoken.
#' 
#' So, after the starting numbers, each turn results in that player speaking 
#' aloud either 0 (if the last number is new) or an age (if the last number is 
#' a repeat).
#' 
#' For example, suppose the starting numbers are 0,3,6:
#' 
#'     - Turn 1: The 1st number spoken is a starting number, 0.
#'     - Turn 2: The 2nd number spoken is a starting number, 3.
#'     - Turn 3: The 3rd number spoken is a starting number, 6.
#'     - Turn 4: Now, consider the last number spoken, 6. Since that was the 
#'       first time the number had been spoken, the 4th number spoken is 0.
#'     - Turn 5: Next, again consider the last number spoken, 0. Since it had 
#'       been spoken before, the next number to speak is the difference between 
#'       the turn number when it was last spoken (the previous turn, 4) and the 
#'       turn number of the time it was most recently spoken before then 
#'       (turn 1). Thus, the 5th number spoken is 4 - 1, 3.
#'     - Turn 6: The last number spoken, 3 had also been spoken before, most 
#'       recently on turns 5 and 2. So, the 6th number spoken is 5 - 2, 3.
#'     - Turn 7: Since 3 was just spoken twice in a row, and the last two turns 
#'       are 1 turn apart, the 7th number spoken is 1.
#'     - Turn 8: Since 1 is new, the 8th number spoken is 0.
#'     - Turn 9: 0 was last spoken on turns 8 and 4, so the 9th number spoken 
#'       is the difference between them, 4.
#'     - Turn 10: 4 is new, so the 10th number spoken is 0.
#' 
#' (The game ends when the Elves get sick of playing or dinner is ready, 
#' whichever comes first.)
#' 
#' Their question for you is: what will be the 2020th number spoken? In the 
#' example above, the 2020th number spoken will be 436.
#' 
#' Here are a few more examples:
#' 
#'     - Given the starting numbers 1,3,2, the 2020th number spoken is 1.
#'     - Given the starting numbers 2,1,3, the 2020th number spoken is 10.
#'     - Given the starting numbers 1,2,3, the 2020th number spoken is 27.
#'     - Given the starting numbers 2,3,1, the 2020th number spoken is 78.
#'     - Given the starting numbers 3,2,1, the 2020th number spoken is 438.
#'     - Given the starting numbers 3,1,2, the 2020th number spoken is 1836.
#' 
#' Given your starting numbers, what will be the 2020th number spoken?
#' 
#' Your puzzle input is 2,0,1,7,4,14,18.

library(testthat)  # For tests

# Given a starting sequence `start_vec` and a number `n`, returns the `n`th 
# number of the elve's counting game, according to the rules in the puzzle
# instructions. Note, the `rounds` vector below contains, at each index, the
# last round (prior to the most recent round) that the number (index - 1) was
# spoken. This is because R is 1-indexed, so the value for '0' is stored in
# index '1' and so on.
number_spoken <- function(start_vec, n) {
  rounds <- numeric(0)                 # Empty vector for the round a number was last spoken
  start_len <- length(start_vec)       # Length of the `start_vec`
  last_number <- start_vec[start_len]  # Last number spoken, starting value
  
  # Fill in the starting numbers into `rounds`
  for (i in 1:start_len) { rounds[[start_vec[i]+1]] <- i }
  
  # For each number after the starting veector...
  for (i in (start_len+1):n) {
    index <- last_number + 1  # Correction for 1-indexing
    
    # If the `index` either contains the number of the last round or an NA, 
    # then the last round was the first time `last_number` was spoken and the
    # `next_number` should be '0'. Otherwise, the `next_number` should be the
    # number of the last round (i-1) minus the number of the previous round
    # in which the number was spoken (rounds[last_number+1])
    next_number <- if (is.na(rounds[index]) || rounds[index] == i - 1) {
      0
    } else {
      (i - 1) - rounds[last_number+1]
    }
    
    rounds[last_number+1] <- i - 1  # Update the round number stored for this number
    last_number <- next_number      # The new `last_number` is this `next_number`
    
    # Sanity Check
    if (i %% 10000 == 0) { cat('\r', paste('Simulating round:', i)) }
  }
  
  next_number  # Return the `n`th number spoken
}

test_that("sample inputs return expected results", {
  expect_equal(number_spoken(c(0, 3, 6), 2020), 436)
  expect_equal(number_spoken(c(1, 3, 2), 2020), 1)
  expect_equal(number_spoken(c(1, 2, 3), 2020), 27)
  expect_equal(number_spoken(c(2, 3, 1), 2020), 78)
  expect_equal(number_spoken(c(3, 2, 1), 2020), 438)
  expect_equal(number_spoken(c(3, 1, 2), 2020), 1836)
})

answer1 <- number_spoken(c(2, 0, 1, 7, 4, 14, 18), 2020)

# Answer: 496
