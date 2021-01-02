#' **--- Day 19: Monster Messages ---**
#'   
#' You land in an airport surrounded by dense forest. As you walk to your 
#' high-speed train, the Elves at the Mythical Information Bureau contact you 
#' again. They think their satellite has collected an image of a sea monster! 
#' Unfortunately, the connection to the satellite is having problems, and many 
#' of the messages sent back from the satellite have been corrupted.
#' 
#' They sent you a list of the rules valid messages should obey and a list of 
#' received messages they've collected so far (your puzzle input).
#' 
#' The rules for valid messages (the top part of your puzzle input) are 
#' numbered and build upon each other. For example:
#' 
#' 0: 1 2
#' 1: "a"
#' 2: 1 3 | 3 1
#' 3: "b"
#' 
#' Some rules, like 3: "b", simply match a single character (in this case, b).
#' 
#' The remaining rules list the sub-rules that must be followed; for example, 
#' the rule 0: 1 2 means that to match rule 0, the text being checked must 
#' match rule 1, and the text after the part that matched rule 1 must then 
#' match rule 2.
#' 
#' Some of the rules have multiple lists of sub-rules separated by a pipe (|). 
#' This means that at least one list of sub-rules must match. (The ones that 
#' match might be different each time the rule is encountered.) For example, 
#' the rule 2: 1 3 | 3 1 means that to match rule 2, the text being checked must 
#' match rule 1 followed by rule 3 or it must match rule 3 followed by rule 1.
#' 
#' Fortunately, there are no loops in the rules, so the list of possible matches 
#' will be finite. Since rule 1 matches a and rule 3 matches b, rule 2 matches 
#' either ab or ba. Therefore, rule 0 matches aab or aba.
#' 
#' Here's a more interesting example:
#'   
#' 0: 4 1 5
#' 1: 2 3 | 3 2
#' 2: 4 4 | 5 5
#' 3: 4 5 | 5 4
#' 4: "a"
#' 5: "b"
#' 
#' Here, because rule 4 matches a and rule 5 matches b, rule 2 matches two 
#' letters that are the same (aa or bb), and rule 3 matches two letters that 
#' are different (ab or ba).
#' 
#' Since rule 1 matches rules 2 and 3 once each in either order, it must match 
#' two pairs of letters, one pair with matching letters and one pair with 
#' different letters. This leaves eight possibilities: aaab, aaba, bbab, bbba, 
#' abaa, abbb, baaa, or babb.
#' 
#' Rule 0, therefore, matches a (rule 4), then any of the eight options from 
#' rule 1, then b (rule 5): aaaabb, aaabab, abbabb, abbbab, aabaab, aabbbb, 
#' abaaab, or ababbb.
#' 
#' The received messages (the bottom part of your puzzle input) need to be 
#' checked against the rules so you can determine which are valid and which are 
#' corrupted. Including the rules and the messages together, this might look 
#' like:
#'   
#' 0: 4 1 5
#' 1: 2 3 | 3 2
#' 2: 4 4 | 5 5
#' 3: 4 5 | 5 4
#' 4: "a"
#' 5: "b"
#' 
#' ababbb
#' bababa
#' abbbab
#' aaabbb
#' aaaabbb
#' 
#' Your goal is to determine the number of messages that completely match rule 
#' 0. In the above example, ababbb and abbbab match, but bababa, aaabbb, and 
#' aaaabbb do not, producing the answer 2. The whole message must match all of 
#' rule 0; there can't be extra unmatched characters in the message. (For 
#' example, aaaabbb might appear to match rule 0 above, but it has an extra 
#' unmatched b on the end.)
#' 
#' How many messages completely match rule 0?

# Setup ------------------------------------------------------------------------
test_input <- c(
  '0: 4 1 5',
  '1: 2 3 | 3 2',
  '2: 4 4 | 5 5',
  '3: 4 5 | 5 4',
  '4: "a"',
  '5: "b"',
  "",
  "ababbb",
  "bababa",
  "abbbab",
  "aaabbb",
  "aaaabbb"
)
real_input <- readLines('input.txt')

# Functions --------------------------------------------------------------------

# Helper function, extracts a pattern-match from a string
extract <- function(str, pattern) {
  regmatches(str, regexpr(pattern, str, perl = TRUE))
}

# Helper function, given a vector of input lines, returns a named vector of 
# parsed validation rules
get_rules <- function(input) {
  input <- gsub('["\']', '', input, )      # Strip any quotes
  split_index <- which(input == "")        # Identify the blank line
  rule_strs <- input[1:(split_index-1)]    # All lines above the blank line
  
  rule_keys <- extract(rule_strs, '^\\d+')         # Rule name, the leading number
  rule_values <- extract(rule_strs, "(?<=: ).+$")  # Everything after the ':'

  # Wrap the values in regex capture groups, except for the static 'a' and 'b'
  # rule values
  root_rule_i <- grepl('[ab]', rule_values)
  rule_values[!root_rule_i] <- paste('(', rule_values[!root_rule_i], ')')
  
  names(rule_values) <- rule_keys  # Add names to the vector of rules
  rule_values
}

# Helper function, given a vector of input lines, returns a vector of 
# messages to validate
get_messages <- function(input) {
  input <- gsub('["\']', '', input)
  split_index <- which(input == "")
  as.character(input[(split_index+1):length(input)])
}

# Helper function, given a rule name (`key`) and the list of validation rules 
# (`rules`), returns the rule text if the rule is in the list of rules, 
# otherwise returns the given `key`. Sometimes, this function will receive
# 'a' and 'b' as `key`s, so it just gives those back.
fetch_if_exists <- function(key, rules) {
  rule <- gsub('[\\^\\$]', '', rules[key])
  if (is.null(rule)) { key } else { rule }
}

# Helper function, given a validation rule `rule`, returns all the references
# to other validation rules.
extract_rule_names <- function(rule) {
  unique(unlist(extract(rule, '\\d+')))
}

# Helper function, given a reference to a validation rule `rule_name` and the 
# list of validation rules `rules`, continuously evaluates the references to
# other validation rules contained in rule `rule_name` until it contains no
# more rule references, then returns the result.
expand_rule <- function(rule_name, rules) {
  rule <- gsub('[\\^\\$]', '', rules[rule_name])  # Remove the string start/end matches
  
  # So long as the rule string contains references to other rules...
  while (grepl('\\d', rule)) {
    
    rule_names <- extract_rule_names(rule)  # The referenced rule names
    
    # Replace each referenced rule name with the text of the referenced rule
    for (name in rule_names) {
      # Wrap the name in word boundaries, to avoid replacing part of a 
      # reference, i.e. the '5' in '15', for example
      pattern <- paste0('\\b', name, '\\b')
      replacement <- fetch_if_exists(name, rules)
      rule <- gsub(pattern, replacement, rule, perl = T)
    }
    
  }
  
  # Remove spaces and add the string start/end matches back
  paste0('^', gsub(' ', '', rule), '$')  
}

# Processing -------------------------------------------------------------------
input_to_process <- real_input              # Which input to process
rules <- get_rules(input_to_process)        # Get rules
messages <- get_messages(input_to_process)  # Get messages
rule0 <- expand_rule('0', rules)            # Expand rule['0'] to regex

# Check each message against rule['0'] to see if it matches
matches <- sapply(messages, function(x) grepl(rule0, x, perl = TRUE))
answer1 <- sum(matches)  # The number of matches

# Answer: 162
