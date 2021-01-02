# --- Part Two ---
#   
# Due to what you can only assume is a mistranslation (you're not exactly 
# fluent in Crab), you are quite surprised when the crab starts arranging many 
# cups in a circle on your raft - one million (1000000) in total.
# 
# Your labeling is still correct for the first few cups; after that, the 
# remaining cups are just numbered in an increasing fashion starting from the 
# number after the highest number in your list and proceeding one by one until 
# one million is reached. (For example, if your labeling were 54321, the cups 
# would be numbered 5, 4, 3, 2, 1, and then start counting up from 6 until one 
# million is reached.) In this way, every number from one through one million 
# is used exactly once.
# 
# After discovering where you made the mistake in translating Crab Numbers, you 
# realize the small crab isn't going to do merely 100 moves; the crab is going 
# to do ten million (10000000) moves!
#                                                          
# The crab is going to hide your stars - one each - under the two cups that 
# will end up immediately clockwise of cup 1. You can have them if you predict 
# what the labels on those cups will be when the crab is finished.
# 
# In the above example (389125467), this would be 934001 and then 159792; 
# multiplying these together produces 149245887792.
# 
# Determine which two cups will end up immediately clockwise of cup 1. What do 
# you get if you multiply their labels together?

# Setup ------------------------------------------------------------------------
                
source('exercise_1.R')


# Functions --------------------------------------------------------------------

# Now add the range from 10 to one million to our cup labels. Yeesh.
parse_input <- function(input) {
  input %>% 
    as.character() %>% 
    strsplit('') %>% 
    unlist %>% 
    as.numeric() %>% 
    c(10:1000000)
}


# Processing -------------------------------------------------------------------

move_cups <- crab_mover(real_input)  # Set up the game

# Progress the game 10 MILLION times, with a progress bar to keep tabs
rounds <- 10000000
pb <- txtProgressBar(min = 0, max = rounds, style = 3)
for (i in 1:rounds) {
  if (i %% 100000 == 0) { setTxtProgressBar(pb, i)}  # Update `pb` at each %
  move_cups()
}
close(pb)

e <- environment(move_cups)                        # Extract the environment
next_one <- e$cups[e$next_i[e$val_map[1]]]         # First cup after '1'
next_two <- e$cups[e$next_i[e$val_map[next_one]]]  # Second cup after '1'
answer2 <- next_one * next_two                     # The answer!

# Answer: 693659135400

