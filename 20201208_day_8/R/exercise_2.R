#' **--- Part Two ---**
#'   
#' After some careful analysis, you believe that exactly one instruction is 
#' corrupted.
#' 
#' Somewhere in the program, either a jmp is supposed to be a nop, or a nop is 
#' supposed to be a jmp. (No acc instructions were harmed in the corruption of 
#' this boot code.)
#' 
#' The program is supposed to terminate by attempting to execute an instruction 
#' immediately after the last instruction in the file. By changing exactly one 
#' jmp or nop, you can repair the boot code and make it terminate correctly.
#' 
#' For example, consider the same program from above:
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
#' ``
#' 
#' If you change the first instruction from nop +0 to jmp +0, it would create a 
#' single-instruction infinite loop, never leaving that instruction. If you 
#' change almost any of the jmp instructions, the program will still eventually 
#' find another jmp instruction and loop forever.
#' 
#' However, if you change the second-to-last instruction (from jmp -4 to nop -4), 
#' the program terminates! The instructions are visited in this order:
#'
#' ```
#' nop +0  | 1
#' acc +1  | 2
#' jmp +4  | 3
#' acc +3  |
#' jmp -3  |
#' acc -99 |
#' acc +1  | 4
#' nop -4  | 5
#' acc +6  | 6
#' ```
#' 
#' After the last instruction (acc +6), the program terminates by attempting to 
#' run the instruction below the last instruction in the file. With this change, 
#' after the program terminates, the accumulator contains the value 8 (acc +1, 
#' acc +1, acc +6).
#' 
#' Fix the program so that it terminates normally by changing exactly one jmp 
#' (to nop) or nop (to jmp). What is the value of the accumulator after the 
#' program terminates?

source('exercise_1.R')

# Simulation Approach ----------------------------------------------------------

adjust_instructions <- function(fail_profile, instructions) {
  for (line in rev(fail_profile$run_lines)) {
    test_instructions <- instructions
    current_fun <- instructions[[line]]$name
    if (current_fun == 'jmp') {
      test_instructions[[line]]$name <- 'nop'
    } 
    if (current_fun == 'nop') {
      test_instructions[[line]]$name <- 'jmp'
    }
    
    new_profile <- profile_instructions(test_instructions)
    if (new_profile$successfully_completed) { 
      print(paste0('It was ', line, '!'))  
      return(new_profile) 
    }
  }
  
  new_profile
}

instructions <- parse_instructions(real_input)
fail_profile <- profile_instructions(instructions)
new_profile <- adjust_instructions(fail_profile, instructions)
answer1 <- new_profile$accumulator

# Graph Approach ---------------------------------------------------------------

# Helper function, adds edges from 'jmp' vertices as if they were 'nop'
# vertices and adds edges to 'nop' vertices as if they were 'jmp' vertices
flip_instruction <- function(i, instr_graph) {
  v <- V(instr_graph)[[i]]
  if (v$name == 'jmp') {  
    # Add an edge connecting to the next vertex in sequence
    mod_graph <- add_edges(instr_graph, c(i, i+1))
  }
  if (v$name == 'nop') {
    # Add an edge connection to the next vertex based on `shift` value
    mod_graph <- add_edges(instr_graph, c(i, i + v$shift))
  }
  mod_graph
}

get_path_to_end <- function(instr_graph) {
  # Get the vertex indices for the longest path starting at index 1,
  # AKA the indexes for all the vertices that can be reached from the
  # starting point
  steps <- subcomponent(instr_graph, 1, mode = 'out')  # Reachable vertices

  for (i in rev(steps)) {                # Stepping backwards
    if (instructions[[i]]$name %in% c('jmp', 'nop')) {
      # Flip the instruction at index `i` then test whether the 'end' vertex
      # is reachable from the first vertex. If so, return the accumulator value
      test_graph <- flip_instruction(i, instr_graph)
      path <- all_simple_paths(test_graph, 1, 'end', mode = 'out')
      if (length(path) > 0) { 
        plot(test_graph, vertex.size = 25, margin = 0)
        return(path[[1]]) 
      }
    }
  }
}

instructions <- parse_instructions(test_input)
instr_graph <- instructions_to_graph(instructions)
path_to_end <- get_path_to_end(instr_graph)
answer2 <- sum(path_to_end$acc)

# Brute Graph Approach ---------------------------------------------------------

instructions <- parse_instructions(real_input)
instr_graph <- instructions_to_graph(instructions)

jmp_vertices <- V(instr_graph)[V(instr_graph)$name == 'jmp']
new_edges <- map2(jmp_vertices, jmp_vertices + 1, ~ c(.x, .y))
mod_graph <- add_edges(instr_graph, unlist(new_edges))

nop_vertices <- V(instr_graph)[V(instr_graph)$name == 'nop']
vals <- map_int(instructions, ~ .x$arg) 
shifted_nops <- nop_vertices + vals[nop_vertices]
new_edges <- map2(nop_vertices, shifted_nops, ~ c(.x, .y))
mod_graph <- add_edges(mod_graph, unlist(new_edges))

paths <- all_simple_paths(mod_graph, 1, 'end', mode = 'out')
shortest_path <- paths[[which.min(lengths(paths))]]
answer3 <- sum(shortest_path$acc)
