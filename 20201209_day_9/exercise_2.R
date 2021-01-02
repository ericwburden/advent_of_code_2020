#' **--- Part Two ---**
#'   
#' The final step in breaking the XMAS encryption relies on the invalid number 
#' you just found: you must find a contiguous set of at least two numbers in 
#' your list which sum to the invalid number from step 1.
#' 
#' Again consider the above example:
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
#' In this list, adding up all of the numbers from 15 through 40 produces the 
#' invalid number from step 1, 127. (Of course, the contiguous set of numbers 
#' in your actual list might be much longer.)
#' 
#' To find the encryption weakness, add together the smallest and largest 
#' number in this contiguous range; in this example, these are 15 and 47, 
#' producing 62.
#' 
#' What is the encryption weakness in your XMAS-encrypted list of numbers?

source('exercise_1.R')

# Helper function, given an index `i`, a number `total`, and a numeric vector `vec`,
# attempts to find a contiguous range in `vec` starting with index `i` that 
# sums to `total`
check_index <- function(i, total, vec) {
  next_i <- i + 1    # The current end of the range in `vec` to check
  
  while (next_i <= length(vec)) {
    current_sum <- sum(vec[i:next_i])               # Current contiguous sum
    if (current_sum == total) { return(i:next_i) }  # Success!
    if (current_sum > total)  { return(NULL) }      # No need to check further
    next_i <- next_i + 1                            # Try the next `next_i`
  }
}

# Main function, given a number `total` and a numeric vector `vec`, finds the
# first contiguous segment of `vec` that sums to `total`, working backwards
# from the end of `vec`
contiguous_range_sum <- function(total, vec) {
  for (p in seq(length(vec)-1, 1)) {  # Work backwards from the end
    sum_range <- check_index(p, total, vec)
    if (!is.null(sum_range)) { return(sum_range) }  # NULL if no range is found
  }
  NA_integer_
}

input_as_num <- as.numeric(real_input)
sum_range <- contiguous_range_sum(answer1, input_as_num)
contiguous_nums <- input_as_num[sum_range]
answer2 <- min(contiguous_nums) + max(contiguous_nums)
