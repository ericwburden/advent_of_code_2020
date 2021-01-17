#' **--- Day 18: Operation Order ---**
#'   
#' As you look out the window and notice a heavily-forested continent slowly 
#' appear over the horizon, you are interrupted by the child sitting next to 
#' you. They're curious if you could help them with their math homework.
#' 
#' Unfortunately, it seems like this "math" follows different rules than you 
#' remember.
#' 
#' The homework (your puzzle input) consists of a series of expressions that 
#' consist of addition (+), multiplication (*), and parentheses ((...)). Just 
#' like normal math, parentheses indicate that the expression inside must be 
#' evaluated before it can be used by the surrounding expression. Addition s
#' till finds the sum of the numbers on both sides of the operator, and 
#' multiplication still finds the product.
#' 
#' However, the rules of operator precedence have changed. Rather than 
#' evaluating multiplication before addition, the operators have the same 
#' precedence, and are evaluated left-to-right regardless of the order in which 
#' they appear.
#' 
#' For example, the steps to evaluate the expression 1 + 2 * 3 + 4 * 5 + 6 are 
#' as follows:
#' 
#' 1 + 2 * 3 + 4 * 5 + 6
#'   3   * 3 + 4 * 5 + 6
#'       9   + 4 * 5 + 6
#'          13   * 5 + 6
#'              65   + 6
#'                  71
#' 
#' Parentheses can override this order; for example, here is what happens if 
#' parentheses are added to form 1 + (2 * 3) + (4 * (5 + 6)):
#' 
#' 1 + (2 * 3) + (4 * (5 + 6))
#' 1 +    6    + (4 * (5 + 6))
#'      7      + (4 * (5 + 6))
#'      7      + (4 *   11   )
#'      7      +     44
#'             51
#' 
#' Here are a few more examples:
#' 
#'     2 * 3 + (4 * 5) becomes 26.
#'     5 + (8 * 3 + 9 + 3 * 4 * 3) becomes 437.
#'     5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4)) becomes 12240.
#'     ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2 becomes 13632.
#' 
#' Before you can help with the homework, you need to understand it yourself. 
#' Evaluate the expression on each line of the homework; what is the sum of the 
#' resulting values?

library(stringr)  # For all the `str_*()` functions
library(stringi)  # For `stri_replace_all_fixed()`

test_input <- c(
  "2 * 3 + (4 * 5)",
  "5 + (8 * 3 + 9 + 3 * 4 * 3)",
  "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))",
  "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"
)
real_input <- readLines('../input.txt')


# Given a string with at least some part contained in parentheses 
# `parens_w_contents`, return the string inside the parentheses
parens_contents <- function(parens_w_contents) {
  str_extract(parens_w_contents, '(?<=\\().+(?=\\))')
}


# Given a string `exp_part`, return a list of the string components split
# on space sequences
tokenize <- function(exp_part) {
  str_split(exp_part, '\\s+')
}


# Given a character vector of regex patterns `patterns`, a character vector
# of replacement strings `replacements`, and a string expression `exp`, replace
# each instance of a pattern with the corresponding replacement string in `exp`
sub_value <- function(patterns, replacements, exp) {
  stri_replace_all_fixed(exp, patterns, replacements, vectorize_all = F)
}


# Given a list of character strings `tokens` consisting of either numbers, the
# '+' symbol, or the '*' symbol (notably, no parentheses!) evaluate the tokens
# as a mathematical expression from left to right, as described by the puzzle
# instructions
eval_tokens <- function(tokens) {
  operator <- `+`
  total <- 0
  for (token in tokens) {
    if (str_detect(token, '\\d+')) { 
      next_number <- as.numeric(token)
      total <- operator(total, next_number) 
    } else {
      operator <- match.fun(token)
    }
  }
  total
}


# Given a string containing one or more expressions wrapped in parentheses 
# `exp_w_parens`, evaluate all expressions contained in the innermost set
# of parentheses. 
# Example: `simplify('2 * (3 + (4 * 5) + 6)') => '2 * (3 + 20 + 6)`
# Example: `simplify('(1 + (2 * 3) + (4 + 5)) => '(1 + 6 + 9)`
simplify <- function(exp_w_parens) {
  # Extract all innermost parentheses expressions, with parentheses included
  inner_parens <- str_extract_all(exp_w_parens, '\\([\\d\\s\\+\\*]+\\)')
  
  contents <- lapply(inner_parens, parens_contents)  # Unwrap parentheses
  token_lists <- lapply(contents, tokenize)          # Tokenize the contents
  
  # Evaluate each tokenized `contents` expression
  replacements <- lapply(token_lists, function(x) { lapply(x, eval_tokens) })
  
  # Replace each `inner_parens` string in the original `exp_w_parens` with the
  # evaluated value
  mapply(sub_value, inner_parens, replacements, MoreArgs = list(exp = exp_w_parens))
}


# Given a list of expressions `exps`, repeatedly simplify and evaluate the 
# innermost parenthetical expressions until the expression has been reduced
# to a single value, as shown in the example. As follows:
# '2 * 3 + (4 * 5)' => '2 * 3 + 20' => '6 + 20' => 26
eval_exps <- function(exps) {
  # If the expression contains any parenthetical components, evaluate them
  # starting with the innermost parenthetical components and working outwards
  needs_simplifying <- str_detect(exps, '[\\(\\)]')
  while (any(needs_simplifying)) {
    exps[needs_simplifying] <- lapply(exps[needs_simplifying], simplify)
    needs_simplifying <- str_detect(exps, '[\\(\\)]')
  }
  
  # Once `exps` has been converted entirely to simple tokens, evaluate
  # the entire remaining expressions to a numeric vector
  vapply(tokenize(exps), eval_tokens, numeric(1))
}

results <- eval_exps(real_input)  # Evaluate all the things!
answer1 <- sum(results)           # Sum the results

# Answer: 131076645626
