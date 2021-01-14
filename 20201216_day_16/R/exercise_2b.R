#' **--- Part Two ---**
#'   
#' Now that you've identified which tickets contain invalid values, discard 
#' those tickets entirely. Use the remaining valid tickets to determine which 
#' field is which.
#' 
#' Using the valid ranges for each field, determine what order the fields 
#' appear on the tickets. The order is consistent between all tickets: if seat 
#' is the third field, it is the third field on every ticket, including your 
#' ticket.
#' 
#' For example, suppose you have the following notes:
#' 
#' class: 0-1 or 4-19
#' row: 0-5 or 8-19
#' seat: 0-13 or 16-19
#' 
#' your ticket:
#' 11,12,13
#' 
#' nearby tickets:
#' 3,9,18
#' 15,1,5
#' 5,14,9
#' 
#' Based on the nearby tickets in the above example, the first position must be 
#' row, the second position must be class, and the third position must be seat; 
#' you can conclude that in your ticket, class is 12, row is 11, and seat is 13.
#' 
#' Once you work out which field is which, look for the six fields on your 
#' ticket that start with the word departure. What do you get if you multiply 
#' those six values together?

source('exercise_1b.R')

test_input <- c(
  "class: 0-1 or 4-19",
  "row: 0-5 or 8-19",
  "seat: 0-13 or 16-19",
  "",
  "your ticket:",
  "11,12,13",
  "",
  "nearby tickets:",
  "3,9,18",
  "15,1,5",
  "5,14,9"
)

input_environment <- parse_input(real_input)  # Unpack the input

# Parse the input data into a data frame indicating matches against the field
# test functions
field_matches <- get_field_matches(
  input_environment$nearby_tickets, 
  input_environment$field_tests
) 

# Get a data frame containing only valid tickets:
# - Group by `ticket_no`, `field_no`, and `field_val`
# - Mark any fields containing invalid data with `invalid_field` = TRUE
# - Group by `ticket_no`
# - Mark any tickets containing invalid fields with `exclude` = TRUE
# - Ungroup and remove any tickets containing invalid fields
valid_ticket_data <- field_matches %>% 
  group_by(ticket_no, field_no, field_val) %>% 
  mutate(invalid_field = !any(match)) %>% 
  group_by(ticket_no) %>% 
  mutate(exclude = any(invalid_field)) %>% 
  ungroup() %>% 
  filter(!exclude)

# Get a data frame consisting of one row per `field_no`, per `field` name where
# all fields in that number matched a particular field test (for example, all
# values in `field_no` 1 matched the 'arrival_platform' field):
# - Group by `field_no` and `field`
# - Identify groups where the `field_no` matched a particular field test every time
# - Filter, keeping only those groups
identify_fields <- valid_ticket_data %>% 
  group_by(field_no, field) %>% 
  summarise(all_matched = all(match)) %>% 
  filter(all_matched)

# Create an empty data frame with columns for `field_no` and `field`
confirmed_fields <- data.frame(field_no = numeric(0), field = character(0))

# Until all records in `identify_fields` have been transferred to 
# `confirmed_fields`
while (nrow(confirmed_fields) < length(unique(identify_fields$field))) {
  
  # Identify fields that only match one set of field rules, sequentially. On the
  # first pass, many of the `field_no`s will satisfy more than one field test, 
  # so we start by transferring the `field_no`s that only match one test to
  # `confirmed_fields`:
  # - Starting with `identify_fields`
  # - Remove any records containing a `field_no` that has already been confirmed
  # - Group by `field`
  # - Calculate the number of records in the group as `group_size`
  # - Filter, keeping only `field`s where the `group_size` is 1, indicating that
  #   that `field_no` only matches that field's requirements
  # - Select the `field_no` and `field` columns
  newly_confirmed <- identify_fields %>% 
    filter(!(field_no %in% confirmed_fields$field_no)) %>% 
    group_by(field) %>% 
    mutate(group_size = n()) %>% 
    filter(group_size == 1) %>% 
    select(field_no, field)
    
  # Add `newly_confirmed` rows to `confirmed_fields`
  confirmed_fields <- bind_rows(confirmed_fields, newly_confirmed)
}

# Starting with the data frame of confirmed field names/numbers, filter the 
# data frame to only 'departure' fields and pull out the `field_no` column
# as a vector
departure_field_nos <- confirmed_fields %>% 
  filter(str_detect(field, 'departure')) %>% 
  pull(field_no)


# Now that we know which `field_no`s (i.e., ticket vector indices) belong to 
# the 'departure' fields, just select those values from `my_ticket` and 
# multiply together
answer2 <- prod(input_environment$my_ticket[departure_field_nos])

# Answer: 2628667251989
