#' **--- Part Two ---**
#'   
#' You manage to answer the child's questions and they finish part 1 of their 
#' homework, but get stuck when they reach the next section: advanced math.
#' 
#' Now, addition and multiplication have different precedence levels, but 
#' they're not the ones you're familiar with. Instead, addition is evaluated 
#' before multiplication.
#' 
#' For example, the steps to evaluate the expression 1 + 2 * 3 + 4 * 5 + 6 are 
#' now as follows:
#' 
#' 1 + 2 * 3 + 4 * 5 + 6
#'   3   * 3 + 4 * 5 + 6
#'   3   *   7   * 5 + 6
#'   3   *   7   *  11
#'      21       *  11
#'          231
#' 
#' Here are the other examples from above:
#' 
#' - 1 + (2 * 3) + (4 * (5 + 6)) still becomes 51.
#' - 2 * 3 + (4 * 5) becomes 46.
#' - 5 + (8 * 3 + 9 + 3 * 4 * 3) becomes 1445.
#' - 5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4)) becomes 669060.
#' - ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2 becomes 23340.
#' 
#' What do you get if you add up the results of evaluating the homework 
#' problems using these new rules?

source('exercise_1.R')

test_input <- c(
  "1 + (2 * 3) + (4 * (5 + 6))",
  "2 * 3 + (4 * 5)",
  "5 + (8 * 3 + 9 + 3 * 4 * 3)",
  "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))",
  "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"
)


# Given a list of character strings `tokens` consisting of either numbers, the
# '+' symbol, or the '*' symbol (notably, no parentheses!) evaluate the tokens
# as a mathematical expression as described in the puzzle input
# Example: '2 * 3 + (4 * 5)' => '2 * 3 + 20' => '2 * 23' => '46'
eval_tokens <- function(tokens) {
  total <- 0                 # Running total
  summed_nums <- numeric(0)  # List of summed numbers
  
  # For each token in the list...
  for (token in tokens) {
    
    if (str_detect(token, '\\d+')) { 
      # If the token is a number, then add it to the running total
      next_number <- as.numeric(token)
      total <- total + next_number
    } else if (token == '*') {
      # Otherwise, if the token is a '*' operator, append the running total to 
      # the vector `summed_nums`, then restart the total
      summed_nums <- c(summed_nums, total)
      total <- 0
    }
    
    # Just ignore the '+' operators...
  }
  
  # Finally, multiply all the `summed_nums` (and `total`) together
  prod(summed_nums, total)  
}

results <- eval_exps(real_input)  # Evaluate again!
answer2 <- sum(results)           # Sum the results

# Answer: 109418509151782
