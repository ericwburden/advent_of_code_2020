#' **--- Day 16: Ticket Translation ---**
#'   
#' As you're walking to yet another connecting flight, you realize that one of 
#' the legs of your re-routed trip coming up is on a high-speed train. However, 
#' the train ticket you were given is in a language you don't understand. You 
#' should probably figure out what it says before you get to the train station 
#' after the next flight.
#' 
#' Unfortunately, you can't actually read the words on the ticket. You can, 
#' however, read the numbers, and so you figure out the fields these tickets 
#' must have and the valid ranges for values in those fields.
#' 
#' You collect the rules for ticket fields, the numbers on your ticket, and the 
#' numbers on other nearby tickets for the same train service (via the airport 
#' security cameras) together into a single document you can reference (your 
#' puzzle input).
#' 
#' The rules for ticket fields specify a list of fields that exist somewhere 
#' on the ticket and the valid ranges of values for each field. For example, a 
#' rule like class: 1-3 or 5-7 means that one of the fields in every ticket is 
#' named class and can be any value in the ranges 1-3 or 5-7 (inclusive, such 
#' that 3 and 5 are both valid in this field, but 4 is not).
#' 
#' Each ticket is represented by a single line of comma-separated values. The 
#' values are the numbers on the ticket in the order they appear; every ticket 
#' has the same format. For example, consider this ticket:
#' 
#' .--------------------------------------------------------.
#' | ????: 101    ?????: 102   ??????????: 103     ???: 104 |
#' |                                                        |
#' | ??: 301  ??: 302             ???????: 303      ??????? |
#' | ??: 401  ??: 402           ???? ????: 403    ????????? |
#' --------------------------------------------------------'
#' 
#' Here, ? represents text in a language you don't understand. This ticket 
#' might be represented as 101,102,103,104,301,302,303,401,402,403; of course, 
#' the actual train tickets you're looking at are much more complicated. In any 
#' case, you've extracted just the numbers in such a way that the first number 
#' is always the same specific field, the second number is always a different 
#' specific field, and so on - you just don't know what each position actually 
#' means!
#' 
#' Start by determining which tickets are completely invalid; these are tickets 
#' that contain values which aren't valid for any field. Ignore your ticket for 
#' now.
#' 
#' For example, suppose you have the following notes:
#'   
#' class: 1-3 or 5-7
#' row: 6-11 or 33-44
#' seat: 13-40 or 45-50
#' 
#' your ticket:
#' 7,1,14
#' 
#' nearby tickets:
#' 7,3,47
#' 40,4,50
#' 55,2,20
#' 38,6,12
#' 
#' It doesn't matter which position corresponds to which field; you can 
#' identify invalid nearby tickets by considering only whether tickets contain 
#' values that are not valid for any field. In this example, the values on the 
#' first nearby ticket are all valid for at least one field. This is not true 
#' of the other three nearby tickets: the values 4, 55, and 12 are are not 
#' valid for any field. Adding together all of the invalid values produces your 
#' ticket scanning error rate: 4 + 55 + 12 = 71.
#' 
#' Consider the validity of the nearby tickets you scanned. What is your ticket 
#' scanning error rate?

library(stringr)
library(tidyr)
library(dplyr)
library(dequer)

test_input <- c(
  "class: 1-3 or 5-7",
  "row: 6-11 or 33-44",
  "seat: 13-40 or 45-50",
  "", 
  "your ticket:",
  "7,1,14",
  "", 
  "nearby tickets:",
  "7,3,47",
  "40,4,50",
  "55,2,20",
  "38,6,12"
)

real_input <- readLines('../input.txt')


# Given a line from the input for a field test (i.e., in the format of 
# "class: 1-3 or 5-7"), returns a closure that accepts a number and 
# returns TRUE if the number matches one of the defined ranges from the
# input and FALSE if it does not.
field_test_function <- function(line) {
  nums <- as.numeric(str_extract_all(line, '\\d+', simplify = TRUE))
  range_one <- nums[1]:nums[2]
  range_two <- nums[3]:nums[4]
  
  function(n) {
    (n %in% range_one) | (n %in% range_two)
  }
}


# Given a list of input lines `input`, returns an environment containing
# a list of functions for testing fields `field_tests`, a numeric vector
# containing the values from your ticket `my_ticket`, and a list containing
# the values from all the other tickets `nearby_tickets`
parse_input <- function(input) {
  env <- new.env()             # Container environment
  env$field_tests <- list()    # List of functions for testing fields
  env$my_ticket <- numeric(0)  # Vector for 'my ticket' numbers
  nearby_tickets <- stack()    # Stack to hold other ticket numbers
  mode <- 'tests'              # Indicates what the for loop does with current line
  
  # For each line in the input lines...
  for (line in input) {
    if (line == "") { next }  # Skip blank lines
    
    # Set `mode` to parse my ticket data
    if (line == 'your ticket:') { mode <- 'my ticket'; next }
    
    # Set `mode` to parse numbers from other tickets
    if (line == 'nearby tickets:') { mode <- 'other tickets'; next }
    
    # The default, for the first set of input lines create a function for
    # each that will test a number to see if it falls within the given ranges
    if (mode == 'tests') { 
      name <- str_extract(line, '^[\\w\\s]+(?=:)')
      env$field_tests[[name]] <- field_test_function(line)
    }
    
    # For 'my ticket', just get the numbers
    if (mode == 'my ticket') {
      env$my_ticket <- as.numeric(unlist(strsplit(line, ',')))
    }
    
    # For 'other tickets', get the numbers and push them onto the 
    # `nearby_tickets` stack
    if (mode == 'other tickets') {
      ticket_nums <- as.numeric(unlist(strsplit(line, ',')))
      push(nearby_tickets, ticket_nums)
    }
  }
  
  env$nearby_tickets <- as.list(nearby_tickets)  # Stack to list
  env  # Return the environment
}


# Given a list of vectors containing the field data from nearby tickets 
# `nearby_tickets` and a list of tests to determine whether a number satisfies
# the ranges for a given field `field_tests`, builds and returns a data frame
# where each row represents the results of testing single field in a single 
# ticket for a match against the rules for a named field. So, one row per test, 
# per field, per ticket. Includes columns that represent a unique identifier for 
# the ticket `ticket_no`, the order in which that field appears on the ticket 
# `field_no`, the name of the field being tested for `field`, whether the 
# value of that field matched the test for the named field `match`, and the
# value of the field being examined `field_val`
get_field_matches <- function(nearby_tickets, field_tests) {
  
  # Structure for the resulting data frame
  all_results <- data.frame(
    ticket_no = numeric(0)  , field_no = numeric(0),
    field     = character(0), match    = logical(0),
    field_val = numeric(0)
  )
  
  # For each vector in `nearby_tickets`...
  for (ticket_no in 1:length(nearby_tickets)) {
    # Shorthand reference to ticked field values
    field_vals <- nearby_tickets[[ticket_no]]  
    
    # Check each field value against each field test function, convert the
    # results into a data frame
    matches <- sapply(field_tests, function(f) { f(field_vals) }) %>% 
      as.data.frame() %>% 
      mutate(
        ticket_no = ticket_no,
        field_no = row_number(),
        field_val = field_vals
      ) %>% 
      pivot_longer(
        -c('ticket_no', 'field_no', 'field_val'), 
        names_to = 'field', 
        values_to = 'match'
      )
    
    all_results <- bind_rows(all_results, matches)  # Append to our data frame
  }
  
  all_results  # Return the data frame
}

input_environment <- parse_input(real_input)  # Unpack the input

# Parse the input data into a data frame indicating matches against the field
# test functions
field_matches <- get_field_matches(
  input_environment$nearby_tickets, 
  input_environment$field_tests
) 

# Determine the answer:
# - Group the data frame by `ticket_no`, `field_no`, and `field_val`
# - For each group, sum the number of fields where `match` == TRUE
# - Keep only records where no matches were found
# - Extract the `field_val` column as a vector
# - Sum the contents of the `field_val` column
answer1 <- field_matches %>% 
  group_by(ticket_no, field_no, field_val) %>% 
  summarise_at('match', sum) %>% 
  filter(match == 0) %>% 
  pull(field_val) %>% 
  sum()
  

# Answer: 32842


