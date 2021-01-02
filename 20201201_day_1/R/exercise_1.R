#' --- Day 1: Report Repair ---
#'
#' After saving Christmas five years in a row, you've decided to take a
#' vacation at a nice resort on a tropical island. Surely, Christmas will go on
#' without you.
#'
#' The tropical island has its own currency and is entirely cash-only. The gold
#' coins used there have a little picture of a starfish; the locals just call
#' them stars. None of the currency exchanges seem to have heard of them, but
#' somehow, you'll need to find fifty of these coins by the time you arrive so
#' you can pay the deposit on your room.
#'
#' To save your vacation, you need to get all fifty stars by December 25th.
#'
#' Collect stars by solving puzzles. Two puzzles will be made available on
#' each day in the Advent calendar; the second puzzle is unlocked when you
#' complete the first. Each puzzle grants one star. Good luck!
#'
#' Before you leave, the Elves in accounting just need you to fix your expense
#' report (your puzzle input); apparently, something isn't quite adding up.
#'
#' Specifically, they need you to find the two entries that sum to 2020 and
#' then multiply those two numbers together.
#'
#' For example, suppose your expense report contained the following:
#' > 1721
#' > 979
#' > 366
#' > 299
#' > 675
#' > 1456
#'
#' In this list, the two entries that sum to 2020 are 1721 and 299. Multiplying
#' them together produces 1721 * 299 = 514579, so the correct answer is 514579.
#'
#' Of course, your expense report is much larger. Find the two entries that sum
#' to 2020; what do you get if you multiply them together?

input <- readLines('../input.txt')
input_nums <- as.numeric(input)

#' Naive approach depending on there being two and only two numbers in `input`
#' that sum to 2020

minus_2020 <- 2020 - input_nums
adds_to_2020 <- minus_2020[minus_2020 %in% input_nums]
answer <- Reduce('*', adds_to_2020)

#' Two pointer approach

p1 <- 1                   # The first pointer, the beginning of the vector
p2 <- length(input_nums)  # The second pointer, the end of the vector
sorted_input_nums <- sort(input_nums)  # Sorts the numbers in ascending order
current_total <- sorted_input_nums[p1] + sorted_input_nums[p2]

while (p1 < p2 & current_total != 2020) {
  print(c(p1, p2, current_total))
  if (current_total < 2020) { p1 <- p1 + 1 }
  if (current_total > 2020) { p2 <- p2 - 1 }
  current_total <- sorted_input_nums[p1] + sorted_input_nums[p2]
}

answer <- sorted_input_nums[p1] * sorted_input_nums[p2]

#' Animated two pointer approach

pprint <- function(p1, p2, arr) {
  output_arr <- crayon::silver(arr)
  output_arr[p1] <- crayon::bgBlue(crayon::white(arr[p1]))
  output_arr[p2] <- crayon::bgRed(crayon::white(arr[p2]))
  cat('\r', output_arr)
  Sys.sleep(0.5)
}

animated_two_pointer_search <- function(arr, t) {
  p1 <- 1            # The first pointer, the beginning of the vector
  p2 <- length(arr)  # The second pointer, the end of the vector
  current_total <- arr[p1] + arr[p2]

  while (p1 < p2 & current_total != t) {
    pprint(p1, p2, arr)
    if (current_total < t) { p1 <- p1 + 1 }
    if (current_total > t) { p2 <- p2 - 1 }
    current_total <- arr[p1] + arr[p2]
  }

  pprint(p1, p2, arr)
}

test_seq <- sort(c(seq(3, 70, 3), 26))
animated_two_pointer_search(test_seq, 56)


