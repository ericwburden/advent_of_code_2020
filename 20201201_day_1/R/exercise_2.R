#' --- Part Two ---
#'
#' The Elves in accounting are thankful for your help; one of them even offers
#' you a starfish coin they had left over from a past vacation. They offer you
#' a second one if you can find three numbers in your expense report that meet
#' the same criteria.
#'
#' Using the above example again, the three entries that sum to 2020 are 979,
#' 366, and 675. Multiplying them together produces the answer, 241861950.
#'
#' In your expense report, what is the product of the three entries that sum
#' to 2020?

input <- readLines('../input.txt')
input_nums <- as.numeric(input)

# Rainbow table approach ----

rainbow_table <- expand.grid(
  list(first = input_nums, second = input_nums, third = input_nums)
)

addends <- with(rainbow_table, rainbow_table[first + second + third == 2020,])
answer <- addends$first[1] * addends$second[1] * addends$third[1]

#' Two pointer approach

sorted_nums <- sort(input_nums)  # Sorts the numbers in ascending order
minus_2020 <- 2020 - sorted_input_nums

for (i in seq(length(sorted_nums))) {
  num <- minus_2020[i]
  p1 <- 1                   # The first pointer, the beginning of the vector
  p2 <- length(sorted_nums)  # The second pointer, the end of the vector

  current_total <- sorted_nums[p1] + sorted_nums[p2]

  while (p1 < p2 & current_total != num) {
    if (current_total < num) { p1 <- p1 + 1 }
    if (current_total > num) { p2 <- p2 - 1 }
    current_total <- sorted_nums[p1] + sorted_nums[p2]
  }

  if (current_total == num) { break }
}

print(c(sorted_nums[i], sorted_nums[c(p1, p2)]))


# Generic cascading pointers ----

entries_that_sum <- function(total, n, search_space) {
  search_space <- unique(sort(search_space, decreasing = T))
  pointers <- seq(n)
  mp <- n

  while (sum(search_space[pointers]) != total) {
    #' The maximum index for the moving pointer `mp`, the length of the
    #' search_space minus all the pointers 'in front of' the moving pointer
    farthest_point <- length(search_space) - (length(pointers) - mp)

    #' If the moving pointer has moved as far as it can OR the current sum is
    #' less than the total (indicating that moving that pointer forward will
    #' not result in a sum == total):
    #'  - If the moving pointer is the first pointer, the search_space has been
    #'  exhausted, return NA
    #'  - Otherwise, switch to the preceding pointer as the moving pointer
    if (pointers[mp] == farthest_point | sum(search_space[pointers]) < total) {
      if (mp == 1) { return(NA) }
      mp <- mp - 1
    }

    #' Move the moving pointer ahead one
    pointers[mp] <- pointers[mp] + 1

    #' If the moving pointer is not the last pointer in the sequence
    #'  - Calculate how far the current pointer is from the next pointer in the
    #'  series
    #'  - If there is space between the current pointer and the next pointer
    #'    - Stash the current pointer
    #'    - Assign the next pointer in series as the moving pointer
    #'    - Move the new moving pointer to the index immediately after the
    #'    preceding pointer
    if (mp < length(pointers)) {
      distance_to_next_pointer <- pointers[mp + 1] - pointers[mp]
      if (distance_to_next_pointer > 1) {
        last_point <- pointers[mp]
        mp <- mp + 1
        pointers[mp] <- last_point + 1
      }
    }
  }
  search_space[pointers]
}



















