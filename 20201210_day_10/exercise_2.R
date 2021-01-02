#' **--- Part Two ---**
#'   
#' To completely determine whether you have enough adapters, you'll need to 
#' figure out how many different ways they can be arranged. Every arrangement 
#' needs to connect the charging outlet to your device. The previous rules 
#' about when adapters can successfully connect still apply.
#' 
#' The first example above (the one that starts with 16, 10, 15) supports the 
#' following arrangements:
#' 
#' ```
#' (0), 1, 4, 5, 6, 7, 10, 11, 12, 15, 16, 19, (22) - drop 0, 0, 0
#' (0), 1, 4, 5, 6, 7, 10, 12, 15, 16, 19, (22)     - drop 0, 0, 11
#' (0), 1, 4, 5, 7, 10, 11, 12, 15, 16, 19, (22)    - drop 0, 0, 6
#' (0), 1, 4, 5, 7, 10, 12, 15, 16, 19, (22)        - drop 0, 6, 11
#' (0), 1, 4, 6, 7, 10, 11, 12, 15, 16, 19, (22)    - drop 0, 0, 5
#' (0), 1, 4, 6, 7, 10, 12, 15, 16, 19, (22)        - drop 0, 5, 11
#' (0), 1, 4, 7, 10, 11, 12, 15, 16, 19, (22)       - drop 0, 5, 6
#' (0), 1, 4, 7, 10, 12, 15, 16, 19, (22)           - drop 5, 6, 11
#' ```
#' 
#' (The charging outlet and your device's built-in adapter are shown in 
#' parentheses.) Given the adapters from the first example, the total number 
#' of arrangements that connect the charging outlet to your device is 8.
#' 
#' The second example above (the one that starts with 28, 33, 18) has many 
#' arrangements. Here are a few:
#' 
#' ```  
#' (0), 1, 2, 3, 4, 7, 8, 9, 10, 11, 14, 17, 18, 19, 20, 23, 24, 25, 28, 31,
#' 32, 33, 34, 35, 38, 39, 42, 45, 46, 47, 48, 49, (52)
#' 
#' (0), 1, 2, 3, 4, 7, 8, 9, 10, 11, 14, 17, 18, 19, 20, 23, 24, 25, 28, 31,
#' 32, 33, 34, 35, 38, 39, 42, 45, 46, 47, 49, (52)
#' 
#' (0), 1, 2, 3, 4, 7, 8, 9, 10, 11, 14, 17, 18, 19, 20, 23, 24, 25, 28, 31,
#' 32, 33, 34, 35, 38, 39, 42, 45, 46, 48, 49, (52)
#' 
#' (0), 1, 2, 3, 4, 7, 8, 9, 10, 11, 14, 17, 18, 19, 20, 23, 24, 25, 28, 31,
#' 32, 33, 34, 35, 38, 39, 42, 45, 46, 49, (52)
#' 
#' (0), 1, 2, 3, 4, 7, 8, 9, 10, 11, 14, 17, 18, 19, 20, 23, 24, 25, 28, 31,
#' 32, 33, 34, 35, 38, 39, 42, 45, 47, 48, 49, (52)
#' 
#' (0), 3, 4, 7, 10, 11, 14, 17, 20, 23, 25, 28, 31, 34, 35, 38, 39, 42, 45,
#' 46, 48, 49, (52)
#' 
#' (0), 3, 4, 7, 10, 11, 14, 17, 20, 23, 25, 28, 31, 34, 35, 38, 39, 42, 45,
#' 46, 49, (52)
#' 
#' (0), 3, 4, 7, 10, 11, 14, 17, 20, 23, 25, 28, 31, 34, 35, 38, 39, 42, 45,
#' 47, 48, 49, (52)
#' 
#' (0), 3, 4, 7, 10, 11, 14, 17, 20, 23, 25, 28, 31, 34, 35, 38, 39, 42, 45,
#' 47, 49, (52)
#' 
#' (0), 3, 4, 7, 10, 11, 14, 17, 20, 23, 25, 28, 31, 34, 35, 38, 39, 42, 45,
#' 48, 49, (52)
#' ```
#' 
#' In total, this set of adapters can connect the charging outlet to your 
#' device in 19208 distinct arrangements.
#' 
#' You glance back down at your bag and try to remember why you brought so 
#' many adapters; there must be more than a trillion valid ways to arrange 
#' them! Surely, there must be an efficient way to count the arrangements.
#' 
#' What is the total number of distinct ways you can arrange the adapters to 
#' connect the charging outlet to your device?

library(purrr)
source('exercise_1.R')

run_length_to_combo <- function(n) {
   replacements <- c('1' = 1, '2' = 2, '3' = 4, '4' = 7)
   unimplemented <- unique(n[!(n %in% names(replacements))])
   if (length(unimplemented) > 0) {
      stop(paste0(
         'No combinations implemented for [',
         paste(unimplemented, sep = ', '), ' ].'
      ))
   }
   
   map_dbl(n, ~ replacements[as.character(.x)])
}

get_possible_combinations <- function(vec) {
   differences <- vec[-1] - vec[-length(vec)]
   rl <- rle(differences)
   one_run_lengths <- rl$lengths[rl$values == 1]
   ind_run_combos <- run_length_to_combo(one_run_lengths)
   prod(ind_run_combos)
}

input_as_num <- as.numeric(real_input)
sorted_input <- c(0, sort(input_as_num), max(input_as_num) + 3)
possible_combinations <- get_possible_combinations(sorted_input)
answer <- as.character(possible_combinations)
