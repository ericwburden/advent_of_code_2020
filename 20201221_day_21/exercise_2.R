# --- Part Two ---
#   
# Now that you've isolated the inert ingredients, you should have enough 
# information to figure out which ingredient contains which allergen.
# 
# In the above example:
# 
#     mxmxvkd contains dairy.
#     sqjhc contains fish.
#     fvjkl contains soy.
# 
# Arrange the ingredients alphabetically by their allergen and separate them by 
# commas to produce your canonical dangerous ingredient list. (There should not 
# be any spaces in your canonical dangerous ingredient list.) In the above 
# example, this would be mxmxvkd,sqjhc,fvjkl.
# 
# Time to stock your raft with supplies. What is your canonical dangerous 
# ingredient list?

# Setup ------------------------------------------------------------------------

source('exercise_1.R')


# Processing -------------------------------------------------------------------

# Setup, count the number of ingredients that contain an allergen and create an
# empty data frame to add allergen/ingredient combinations to as we confirm
num_allergen_ingredients <- length(unique(possible_allergens$ingredient))
confirmed_allergens <- data.frame(
  allergen = character(0), 
  ingredient = character(0)
)

# Until the number of confirmed allergens is as large as the number of allergens...
while (nrow(confirmed_allergens) < num_allergen_ingredients) {
  
  # Remove all the previously confirmed allergens from the table of possible
  # allergens, then identify which ingredients are now associated with a 
  # single allergen
  newly_confirmed_allergens <- possible_allergens %>% 
    filter(!(allergen %in% confirmed_allergens$allergen)) %>% 
    group_by(ingredient) %>% 
    mutate(n = n()) %>% 
    filter(n == 1) %>% 
    select(-n)
  
  # Add the newly confirmed allergens to the ongoing list of confirmed 
  # allergens
  confirmed_allergens <- bind_rows(
    confirmed_allergens, 
    newly_confirmed_allergens
  )
}

# Sort the table of confirmed allergen/ingredient combinations by allergen name,
# then collapse the ingredient names with commas between
answer2 <- confirmed_allergens %>% 
  arrange(allergen) %>% 
  pull(ingredient) %>% 
  paste(collapse = ',')

