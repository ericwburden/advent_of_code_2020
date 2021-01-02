#' **--- Day 9: Encoding Error ---**
#'   
#' With your neighbor happily enjoying their video game, you turn your 
#' attention to an open data port on the little screen in the seat in front of 
#' you.
#' 
#' Though the port is non-standard, you manage to connect it to your computer 
#' through the clever use of several paperclips. Upon connection, the port 
#' outputs a series of numbers (your puzzle input).
#' 
#' The data appears to be encrypted with the eXchange-Masking Addition System 
#' (XMAS) which, conveniently for you, is an old cypher with an important 
#' weakness.
#' 
#' XMAS starts by transmitting a preamble of 25 numbers. After that, each 
#' number you receive should be the sum of any two of the 25 immediately 
#' previous numbers. The two numbers will have different values, and there 
#' might be more than one such pair.
#' 
#' For example, suppose your preamble consists of the numbers 1 through 25 in a 
#' random order. To be valid, the next number must be the sum of two of those 
#' numbers:
#'   
#' - 26 would be a valid next number, as it could be 1 plus 25 (or many other 
#' pairs, like 2 and 24).
#' - 49 would be a valid next number, as it is the sum of 24 and 25.
#' - 100 would not be valid; no two of the previous 25 numbers sum to 100.
#' - 50 would also not be valid; although 25 appears in the previous 25 
#' numbers, the two numbers in the pair must be different.
#' 
#' Suppose the 26th number is 45, and the first number (no longer an option, 
#' as it is more than 25 numbers ago) was 20. Now, for the next number to be 
#' valid, there needs to be some pair of numbers among 1-19, 21-25, or 45 that 
#' add up to it:
#'   
#' - 26 would still be a valid next number, as 1 and 25 are still within the 
#' previous 25 numbers.
#' - 65 would not be valid, as no two of the available numbers sum to it.
#' - 64 and 66 would both be valid, as they are the result of 19+45 and 21+45 respectively.
#' 
#' - Here is a larger example which only considers the previous 5 numbers (and 
#' has a preamble of length 5):
#' 
#' ```
#' 35
#' 20
#' 15
#' 25
#' 47
#' 40
#' 62
#' 55
#' 65
#' 95
#' 102
#' 117
#' 150
#' 182
#' 127
#' 219
#' 299
#' 277
#' 309
#' 576
#' ```
#' 
#' In this example, after the 5-number preamble, almost every number is the sum 
#' of two of the previous 5 numbers; the only number that does not follow this 
#' rule is 127.
#' 
#' The first step of attacking the weakness in the XMAS data is to find the 
#' first number in the list (after the preamble) which is not the sum of two of 
#' the 25 numbers before it. What is the first number that does not have this 
#' property?

test_input <- c(
   "35",  "20",  "15",  "25",  "47", 
   "40",  "62",  "55",  "65",  "95",
  "102", "117", "150", "182", "127",
  "219", "299", "277", "309", "576"
)

real_input <- readLines('input.txt')

# Helper function, checks a element of numeric vector `vec` at index `i` to
# determine whether the preceding `len` elements contain at least two items
# that sum to `vec[i]`
check_index <- function(i, vec, len) {
  # Some paranoid input validation
  if (i <= len) { stop('`i` must be greater than `len`') }
  if (length(vec) < i) { stop('`vec` must contain at least `i` items') }

  n <- vec[i]                  # Current number to check
  n_vec <- vec[(i-len):(i-1)]  # Preceding `len` elements
  
  # Do at least two numbers appear in both the set of numbers you get when all
  # `n_vec` elements are subtracted from `n` and the original `n_vec` numbers?
  length(intersect(n - n_vec, n_vec)) >= 2
}

# Main function, iterates through numeric vector `vec` and checks each element
# in `vec` at index > `len` to determine whether any two of the `len` elements
# prior to `vec[i]` sums to `vec[i]`. Returns the first `i` where this is not
# true.
first_false <- function(vec, len) {
  check_range <- (len+1):length(vec)  # Only check `vec` items after the `len`th
  
  for (i in check_range) {
    if (!check_index(i, input_as_num, check_n)) { return(i) }
  }

  return(NA)
}

input_as_num <- as.numeric(real_input)
check_n <- 25  # Number of previous items to check, 5 for tests, 25 for real data

answer1 <- input_as_num[first_false(input_as_num, check_n)]



















