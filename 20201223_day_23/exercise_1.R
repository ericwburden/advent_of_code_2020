# --- Day 23: Crab Cups ---
#   
# The small crab challenges you to a game! The crab is going to mix up some 
# cups, and you have to predict where they'll end up.
# 
# The cups will be arranged in a circle and labeled clockwise (your puzzle 
# input). For example, if your labeling were 32415, there would be five cups in 
# the circle; going clockwise around the circle from the first cup, the cups 
# would be labeled 3, 2, 4, 1, 5, and then back to 3 again.
# 
# Before the crab starts, it will designate the first cup in your list as the 
# current cup. The crab is then going to do 100 moves.
# 
# Each move, the crab does the following actions:
# 
#     - The crab picks up the three cups that are immediately clockwise of the 
#     current cup. They are removed from the circle; cup spacing is adjusted as 
#     necessary to maintain the circle.
#     - The crab selects a destination cup: the cup with a label equal to the 
#     current cup's label minus one. If this would select one of the cups that 
#     was just picked up, the crab will keep subtracting one until it finds a 
#     cup that wasn't just picked up. If at any point in this process the value 
#     goes below the lowest value on any cup's label, it wraps around to the 
#     highest value on any cup's label instead.
#     - The crab places the cups it just picked up so that they are immediately 
#     clockwise of the destination cup. They keep the same order as when they 
#     were picked up.
#     - The crab selects a new current cup: the cup which is immediately 
#     clockwise of the current cup.
# 
# For example, suppose your cup labeling were 389125467. If the crab were to do 
# merely 10 moves, the following changes would occur:
# 
# -- move 1 --
# cups: (3) 8  9  1  2  5  4  6  7 
# pick up: 8, 9, 1
# destination: 2
# 
# -- move 2 --
# cups:  3 (2) 8  9  1  5  4  6  7 
# pick up: 8, 9, 1
# destination: 7
# 
# -- move 3 --
# cups:  3  2 (5) 4  6  7  8  9  1 
# pick up: 4, 6, 7
# destination: 3
# 
# -- move 4 --
# cups:  7  2  5 (8) 9  1  3  4  6 
# pick up: 9, 1, 3
# destination: 7
# 
# -- move 5 --
# cups:  3  2  5  8 (4) 6  7  9  1 
# pick up: 6, 7, 9
# destination: 3
# 
# -- move 6 --
# cups:  9  2  5  8  4 (1) 3  6  7 
# pick up: 3, 6, 7
# destination: 9
# 
# -- move 7 --
# cups:  7  2  5  8  4  1 (9) 3  6 
# pick up: 3, 6, 7
# destination: 8
# 
# -- move 8 --
# cups:  8  3  6  7  4  1  9 (2) 5 
# pick up: 5, 8, 3
# destination: 1
# 
# -- move 9 --
# cups:  7  4  1  5  8  3  9  2 (6)
# pick up: 7, 4, 1
# destination: 5
# 
# -- move 10 --
# cups: (5) 7  4  1  8  3  9  2  6 
# pick up: 7, 4, 1
# destination: 3
# 
# -- final --
# cups:  5 (8) 3  7  4  1  9  2  6 
# 
# In the above example, the cups' values are the labels as they appear 
# moving clockwise around the circle; the current cup is marked with ( ).
# 
# After the crab is done, what order will the cups be in? Starting after the 
# cup labeled 1, collect the other cups' labels clockwise into a single string 
# with no extra characters; each number except 1 should appear exactly once. 
# In the above example, after 10 moves, the cups clockwise from 1 are labeled 
# 9, 2, 6, 5, and so on, producing 92658374. If the crab were to complete all 
# 100 moves, the order after cup 1 would be 67384529.
# 
# Using your labeling, simulate 100 moves. What are the labels on the cups 
# after cup 1?

# Setup ------------------------------------------------------------------------

test_input <- c(389125467)
real_input <- c(198753462)

library(igraph)    # For plotting networks, debugging
library(magrittr)  # Provides the `%>%` pipe operator


# Functions --------------------------------------------------------------------

# Given a vector of cup labels `cups`, a vector indicating the next cup in
# sequence `next_i`, the index (in `cups`) of the current cup `current_i`, 
# the index (in `cups`) of the destination cup `destination_i`, and the indices
# (in `cups`)  of any cups that have been picked up `picked_up_i`, plots
# a network diagram of the current state of the cups game
pplot <- function(cups, next_i, current_i, destination_i, picked_up_i) {
  g <- graph_from_edgelist(cbind(cups, cups[next_i])) %>% 
    set_vertex_attr('current', value = F) %>% 
    set_vertex_attr('current', index = cups[current_i], value = T) %>% 
    set_vertex_attr('destination', value = F) %>% 
    set_vertex_attr('destination', index = cups[destination_i], value = T) %>%
    set_vertex_attr('picked_up', value = F) %>% 
    set_vertex_attr('picked_up', index = cups[picked_up_i], value = T)
  
  V(g)$color <- ifelse(V(g)$destination, 'coral', 'lightgreen')
  V(g)$color <- ifelse(V(g)$current, 'lightblue', V(g)$color)
  V(g)$color <- ifelse(V(g)$picked_up, 'purple', V(g)$color)
  plot(g)
}


# Given the closure containing all the elements of the cup game in its 
# enclosing environment, extracts those elements from the enclosing environemnt
# and passes them to `pplot()`
pplot_func <- function(f) {
  e <- environment(f)
  pplot(e$cups, e$next_i, e$current_i, e$destination_i, e$picked_up_i)
}


# Given a number representing cup labels in order, returns a numeric vector
# representing cup labels, in order
parse_input <- function(input) {
  input %>% 
    as.character() %>% 
    strsplit('') %>% 
    unlist %>% 
    as.numeric()
}


# A closure whose enclosing environment will contain the current state of the
# cups game, including:
# - a vector representing the cup labels in the initial order `cups`
# - a vector where the value at each index represents the index of the next 
#   cup (in `cups`) in series `next_i` (Example, `cups[next_i[3]]` is the next 
#   cup in sequence after cup `3`)
# - a vector where the value at each index `i` represents the index in `cups`
#   containing the value `i`, essentially a reverse lookup for `cups` (Example,
#   `val_map[3]` returns the index in `cups` for the value `3`)
# - the maximum value of a cup label `max_cup`
# - a number representing the index in `cups` for the 'current' cup `current_i`
# - a number representing the index in `cups` for the `destination` cup 
#   `destination_i`
# - a vector representing the indices in `cups` for the cups that have been 
#   picked up `picked_up_i`
#   
# Returns a function that advances the game state according to the rules of 
# the game as described in the puzzle instructions
crab_mover <- function(input) {
  
  # Values representing the current game state, see comment for `crab_mover()`
  # for explanations of each
  cups <- parse_input(input)
  next_i <- c(2:length(cups), 1)
  val_map <- sort.list(cups)
  max_cup <- max(cups)
  
  current_i <- 1
  destination_i <- 0
  picked_up_i <- 0
  
  function() {
    # Pick up three cups. Note the use of the `<<-` assignment operator, 
    # assigning the values to `picked_up_i` in the enclosing environment
    picked_up_i <<- c(
      next_i[current_i],
      next_i[next_i[current_i]],
      next_i[next_i[next_i[current_i]]]
    )
    
    # Close the circle, setting the `next_i` for the current cup to the cup
    # after the last cup picked up
    next_i[current_i] <<- next_i[picked_up_i[3]]
    
    # Identify the 'destination' cup, the next cup in reverse label order from
    # the current cup. Can't be one of the cups picked up. If there are no cups
    # with labels lower than the current cup, loop back to the top of the cup 
    # label range (`max_cup`)
    destination_value <- cups[current_i]
    invalid_values <- c(destination_value, cups[picked_up_i])
    while (destination_value %in% invalid_values) {
      destination_value <- if (destination_value == 1) { 
        max_cup 
      } else { 
        destination_value - 1 
      }
    }
    destination_i <<- val_map[destination_value]
    
    # Add the picked up cups back to the circle. Set the next cup after the 
    # third picked up cup to the cup following the destination cup. Set the
    # next cup after the destination cup to the first picked up cup.
    next_i[picked_up_i[3]] <<- next_i[destination_i]
    next_i[destination_i] <<- picked_up_i[1]
    
    # Get the next current cup
    current_i <<- next_i[current_i]
  }
}


# Processing -------------------------------------------------------------------

move_cups <- crab_mover(real_input)   # Set up the game
for (i in 1:10) { move_cups() }       # Advance 10 times
e <- environment(move_cups)           # Extract the game state

# Get cup labels, in order, following the cup labeled '1'
current_cup <- 1
cups_in_order <- character(0)
for (i in 1:8) {
  # Get the cup following the cup with the value `current_cup`
  next_cup <- e$cups[e$next_i[e$val_map[current_cup]]]
  cups_in_order <- c(cups_in_order, next_cup)
  current_cup <- next_cup
}
answer1 <- paste(cups_in_order, collapse = '')

# Answer: 52738469
