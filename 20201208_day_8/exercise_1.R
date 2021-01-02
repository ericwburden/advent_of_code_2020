#' **--- Day 8: Handheld Halting ---**
#'   
#' Your flight to the major airline hub reaches cruising altitude without 
#' incident. While you consider checking the in-flight menu for one of those 
#' drinks that come with a little umbrella, you are interrupted by the kid 
#' sitting next to you.
#' 
#' Their handheld game console won't turn on! They ask if you can take a look.
#' 
#' You narrow the problem down to a strange infinite loop in the boot code 
#' (your puzzle input) of the device. You should be able to fix it, but first 
#' you need to be able to run the code in isolation.
#' 
#' The boot code is represented as a text file with one instruction per line of 
#' text. Each instruction consists of an operation (acc, jmp, or nop) and an 
#' argument (a signed number like +4 or -20).
#' 
#' - acc increases or decreases a single global value called the accumulator by 
#' the value given in the argument. For example, acc +7 would increase the 
#' accumulator by 7. The accumulator starts at 0. After an acc instruction, 
#' the instruction immediately below it is executed next.
#' - jmp jumps to a new instruction relative to itself. The next instruction to 
#' execute is found using the argument as an offset from the jmp instruction; 
#' for example, jmp +2 would skip the next instruction, jmp +1 would continue 
#' to the instruction immediately below it, and jmp -20 would cause the 
#' instruction 20 lines above to be executed next.
#' - nop stands for No OPeration - it does nothing. The instruction immediately 
#' below it is executed next.
#' 
#' For example, consider the following program:
#' 
#' ```
#' nop +0
#' acc +1
#' jmp +4
#' acc +3
#' jmp -3
#' acc -99
#' acc +1
#' jmp -4
#' acc +6
#' ```
#' 
#' These instructions are visited in this order:
#' 
#' ```
#' nop +0  | 1
#' acc +1  | 2, 8(!)
#' jmp +4  | 3
#' acc +3  | 6
#' jmp -3  | 7
#' acc -99 |
#' acc +1  | 4
#' jmp -4  | 5
#' acc +6  |
#' ```
#' 
#' First, the nop +0 does nothing. Then, the accumulator is increased from 
#' 0 to 1 (acc +1) and jmp +4 sets the next instruction to the other acc +1 
#' near the bottom. After it increases the accumulator from 1 to 2, jmp -4 
#' executes, setting the next instruction to the only acc +3. It sets the 
#' accumulator to 5, and jmp -3 causes the program to continue back at the 
#' first acc +1.
#' 
#' This is an infinite loop: with this sequence of jumps, the program will run 
#' forever. The moment the program tries to run any instruction a second time, 
#' you know it will never terminate.
#' 
#' Immediately before the program would run an instruction a second time, the 
#' value in the accumulator is 5.
#' 
#' Run your copy of the boot code. Immediately before any instruction is 
#' executed a second time, what value is in the accumulator?

library(stringr)
library(purrr)

test_input <- c(
  "nop +0",
  "acc +1",
  "jmp +4",
  "acc +3",
  "jmp -3",
  "acc -99",
  "acc +1",
  "jmp -4",
  "acc +6"
)
real_input <- readLines('input.txt')

# Simulation approach ----------------------------------------------------------

# Helpful structure, a list containing one function per instruction type
# assigned by name
funs <- list(
  nop = function(accumulator, pointer, arg) {
    list(accumulator = accumulator, pointer = pointer + 1)
  },
  acc = function(accumulator, pointer, arg) {
    list(accumulator = accumulator + arg, pointer = pointer + 1)
  },
  jmp = function(accumulator, pointer, arg) {
    list(accumulator = accumulator, pointer = pointer + arg)
  }
)

# Helper function, given a vector of lines from the input (format 'acc +6'), 
# returns # a nested list object where each list item represents a single 
# instruction and each sublist item contains a [['fun']], which is the name of 
# the instruction and an [['arg']], which is the argument for that line, 
# ex. list(list(fun = 'acc', arg = 6), list(fun = 'nop', arg = -5))
parse_instructions <- function(input) {
  name <- str_extract(input, 'nop|acc|jmp')
  arg <- as.integer(str_extract(input, '[+-]\\d+'))
  
  result <- map2(name, arg, list)
  result <- map(result, setNames, c('name', 'arg'))
  result
}

# Main function, given a set of instructions (produced by 
# `parse_instructions()`), runs the 'code' described and returns the result
# as a list containing the current `accumulator` value, the `pointer` to the
# current line in the instructions, a list of instruction line numbers in the
# order they ran as `run_lines`, and a flag for whether the instruction set
# was terminated by running all the instructions as `successfully_completed`.
profile_instructions <- function(instructions) {
  # These values are all in a list to make it easier to return the entire
  # package at the end
  profile <- list(
    accumulator = 0,
    pointer = 1,
    run_lines = numeric(0),
    successfully_completed = FALSE
  )
  
  # For each instruction in the list, follow that instruction and move
  # to the next instruction as appropriate
  while(profile$pointer <= length(instructions)) {
    current_line <- profile$pointer
    result <- with(
      instructions[[profile$pointer]], 
      funs[[name]](profile$accumulator, profile$pointer, arg)
    )
    
    # If we encounter a loop, return early with the profile
    if (profile$pointer %in% profile$run_lines) { return(profile) }
    
    # Update the profile
    profile$run_lines <- c(profile$run_lines, current_line)
    profile$accumulator <- result$accumulator
    profile$pointer <- result$pointer
  }
  
  # If the instructions run to completion, mark the profile as 
  # `successfully_completed`
  profile$successfully_completed <- TRUE
  profile
}


instructions <- parse_instructions(real_input)
final_profile <- profile_instructions(instructions)
answer1 <- final_profile$accumulator

# Graph Approach ---------------------------------------------------------------

library(igraph)    # For all the graph-related functions 
library(magrittr)  # For the %>% operator

instructions_to_graph <- function(instructions) {
  origins <- seq(length(instructions))        # Current instruction index
  names <- map_chr(instructions, ~ .x$name)   # Instruction name
  vals <- map_int(instructions, ~ .x$arg)     # Instruction value
  shifts <- ifelse(names == 'jmp', vals, 1)   # Amount to move by after instruction
  acc <- ifelse(names == 'acc', vals, 0)  # Amount to add to accumulator
  
  # Build a matrix where one column is the origins and the second column is the
  # represents the index of the next instruction in the sequence, determined
  # by the type and amount of the current instruction
  edge_matrix <- matrix(c(origins, origins + shifts), ncol = 2)

  # Make a graph! Converts the `edge_matrix` to a graph; assigns the 'name'
  # of the instruction to each vertex with a special name ('end') for the 
  # vertex representing the space after the last instruction, assigns
  # the 'shift' of each instruction to each vertex as a `$shift` attribute,
  # assigns the amount added to the accumulator for each instruction to 
  # each vertex as the '$acc' attribute
  graph_from_edgelist(edge_matrix) %>%
    set_vertex_attr('name', value = c(names, 'end')) %>% 
    set_vertex_attr('shift', value = c(shifts, NA)) %>% 
    set_vertex_attr('acc', value = c(acc, 0))
}

instructions <- parse_instructions(test_input)
instr_graph <- instructions_to_graph(instructions)
plot(instr_graph)
operation_path_vertices <- subcomponent(instr_graph, 1, mode = 'out')
answer2 <- sum(operation_path_vertices$acc)
