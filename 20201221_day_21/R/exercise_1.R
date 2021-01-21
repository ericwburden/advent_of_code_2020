# --- Day 21: Allergen Assessment ---
#   
# You reach the train's last stop and the closest you can get to your vacation 
# island without getting wet. There aren't even any boats here, but nothing can 
# stop you now: you build a raft. You just need a few days' worth of food for 
# your journey.
# 
# You don't speak the local language, so you can't read any ingredients lists. 
# However, sometimes, allergens are listed in a language you do understand. 
# You should be able to use this information to determine which ingredient 
# contains which allergen and work out which foods are safe to take with you on 
# your trip.
# 
# You start by compiling a list of foods (your puzzle input), one food per line. 
# Each line includes that food's ingredients list followed by some or all of 
# the allergens the food contains.
# 
# Each allergen is found in exactly one ingredient. Each ingredient contains 
# zero or one allergen. Allergens aren't always marked; when they're listed (as 
# in (contains nuts, shellfish) after an ingredients list), the ingredient that 
# contains each listed allergen will be somewhere in the corresponding 
# ingredients list. However, even if an allergen isn't listed, the ingredient 
# that contains that allergen could still be present: maybe they forgot to 
# label it, or maybe it was labeled in a language you don't know.
# 
# For example, consider the following list of foods:
#   
# mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
# trh fvjkl sbzzf mxmxvkd (contains dairy)
# sqjhc fvjkl (contains soy)
# sqjhc mxmxvkd sbzzf (contains fish)
# 
# The first food in the list has four ingredients (written in a language you 
# don't understand): mxmxvkd, kfcds, sqjhc, and nhms. While the food might 
# contain other allergens, a few allergens the food definitely contains are 
# listed afterward: dairy and fish.
# 
# The first step is to determine which ingredients can't possibly contain any 
# of the allergens in any food in your list. In the above example, none of the 
# ingredients kfcds, nhms, sbzzf, or trh can contain an allergen. Counting the 
# number of times any of these ingredients appear in any ingredients list 
# produces 5: they all appear once each except sbzzf, which appears twice.
#                                                  
# Determine which ingredients cannot possibly contain any of the allergens in 
# your list. How many times do any of those ingredients appear?

# Setup ------------------------------------------------------------------------

test_input <- c(
  "mxmxvkd kfcds sqjhc nhms (contains dairy, fish)",
  "trh fvjkl sbzzf mxmxvkd (contains dairy)",
  "sqjhc fvjkl (contains soy)",
  "sqjhc mxmxvkd sbzzf (contains fish)"
)
real_input <- readLines('../input.txt')

library(dplyr)
library(purrr)


# Functions --------------------------------------------------------------------

# Helper function, given a line number `line_no` and a list where the first
# element is a space-separated vector of ingredients and the second element
# is a space-separated vector of allergens `split_line`, returns a data frame
# with one row for each combination of `line_no` (as 'recipe'), ingredient, 
# and allergen.
line_to_df <- function(line_no, split_line) {
  parts <- strsplit(split_line, ' ')
  expand.grid(
    recipe = line_no, 
    ingredient = parts[[1]], 
    allergen = parts[[2]], 
    stringsAsFactors = F
  )
}

# Helper function, given a list of lines from the puzzle input, returns a 
# data frame containing one row per line number (recipe), ingredient, and
# allergen
parse_input <- function(input) {
  line_count <- length(input)
  only_words <- gsub('[\\(\\),]', '', input)
  split_lines <- strsplit(only_words, 'contains ')
  dfs <- mapply(line_to_df, 1:line_count, split_lines, SIMPLIFY = F)
  do.call(rbind, dfs)
}

# Processing -------------------------------------------------------------------

recipe_list <- parse_input(real_input)  # Parse the input

# For each type of allergen, return a data frame consisting of that allergen
# and all ingredients that appear in all recipes containing that allergen.
possible_allergens <- recipe_list %>% 
  group_by(allergen, recipe) %>% 
  summarise(ingredients = list(ingredient)) %>% 
  summarise(ingredient = reduce(ingredients, intersect))

# Remove all rows containing ingredients that definitely contain an allergen
# (though we're not sure which one), then count the number of ingredient
# and recipe combinations remaining
answer1 <- recipe_list %>% 
  filter(!(ingredient %in% possible_allergens$ingredient)) %>% 
  distinct(recipe, ingredient) %>% 
  nrow()
  
# 2569
