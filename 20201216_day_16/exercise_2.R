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

source('exercise_1.R')
library(stringr)

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

op_env <- parse_input(real_input)
valid_ticket_data <- op_env$all_results %>% 
  group_by(ticket_no, field_no, field_val) %>% 
  mutate(invalid_field = !any(match)) %>% 
  group_by(ticket_no) %>% 
  mutate(exclude = any(invalid_field)) %>% 
  ungroup() %>% 
  filter(!exclude)

identify_fields <- valid_ticket_data %>% 
  group_by(field_no, field) %>% 
  summarise(all_matched = all(match)) %>% 
  filter(all_matched) %>% 
  group_by(field) %>% 
  mutate(n = row_number())

confirmed_fields <- data.frame(field_no = numeric(0), field = character(0))
while (nrow(confirmed_fields) < length(unique(identify_fields$field))) {
  newly_confirmed <- identify_fields %>% 
    filter(!(field_no %in% confirmed_fields$field_no)) %>% 
    group_by(field) %>% 
    mutate(group_size = n()) %>% 
    filter(group_size == 1) %>% 
    select(field_no, field)
    
  confirmed_fields <- bind_rows(confirmed_fields, newly_confirmed)
}

departure_field_nos <- confirmed_fields %>% 
  filter(str_detect(field, 'departure')) %>% 
  pull(field_no)

answer2 <- prod(op_env$my_ticket[departure_field_nos])

# Answer: 2628667251989
