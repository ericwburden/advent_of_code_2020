#'**--- Day 11: Seating System ---**
#'  
#'  Your plane lands with plenty of time to spare. The final leg of your 
#'  journey is a ferry that goes directly to the tropical island where you can 
#'  finally start your vacation. As you reach the waiting area to board the 
#'  ferry, you realize you're so early, nobody else has even arrived yet!
#'
#' By modeling the process people use to choose (or abandon) their seat in
#' the waiting area, you're pretty sure you can predict the best place to sit. 
#' You make a quick map of the seat layout (your puzzle input).
#'
#' The seat layout fits neatly on a grid. Each position is either floor (.), 
#' an empty seat (L), or an occupied seat (#). For example, the initial seat 
#' layout might look like this:
#'  
#' ```
#'  L.LL.LL.LL
#'  LLLLLLL.LL
#'  L.L.L..L..
#'  LLLL.LL.LL
#'  L.LL.LL.LL
#'  L.LLLLL.LL
#'  ..L.L.....
#'  LLLLLLLLLL
#'  L.LLLLLL.L
#'  L.LLLLL.LL
#' ```
#' 
#' Now, you just need to model the people who will be arriving shortly. 
#' Fortunately, people are entirely predictable and always follow a simple 
#' set of rules. All decisions are based on the number of occupied seats 
#' adjacent to a given seat (one of the eight positions immediately up, down, 
#' left, right, or diagonal from the seat). The following rules are applied to 
#' every seat simultaneously:
#'    
#' - *If a seat is empty (L) and there are no occupied seats adjacent to it,*
#'   *the seat becomes occupied.*
#' - *If a seat is occupied (#) and four or more seats adjacent to it are also*
#'   *occupied, the seat becomes empty.*
#' - *Otherwise, the seat's state does not change.*
#'
#' Floor (.) never changes; seats don't move, and nobody sits on the floor.
#'    
#' After one round of these rules, every seat in the example layout becomes occupied:
#'   
#' ```  
#' #.##.##.##
#' #######.##
#' #.#.#..#..
#' ####.##.##
#' #.##.##.##
#' #.#####.##
#' ..#.#.....
#' ##########
#' #.######.#
#' #.#####.##
#' ```
#' 
#'  After a second round, the seats with four or more occupied adjacent seats 
#'  become empty again:
#'      
#'    #.LL.L#.##
#'    #LLLLLL.L#
#'    L.L.L..L..
#'    #LLL.LL.L#
#'    #.LL.LL.LL
#'    #.LLLL#.##
#'    ..L.L.....
#'    #LLLLLLLL#
#'    #.LLLLLL.L
#'    #.#LLLL.##
#'    
#' This process continues for three more rounds:
#'      
#'    #.##.L#.##
#'    #L###LL.L#
#'    L.#.#..#..
#'    #L##.##.L#
#'    #.##.LL.LL
#'    #.###L#.##
#'    ..#.#.....
#'    #L######L#
#'    #.LL###L.L
#'    #.#L###.##
#'    
#'    #.#L.L#.##
#'    #LLL#LL.L#
#'    L.L.L..#..
#'    #LLL.##.L#
#'    #.LL.LL.LL
#'    #.LL#L#.##
#'    ..L.L.....
#'    #L#LLLL#L#
#'    #.LLLLLL.L
#'    #.#L#L#.##
#'    
#'    #.#L.L#.##
#'    #LLL#LL.L#
#'    L.#.L..#..
#'    #L##.##.L#
#'    #.#L.LL.LL
#'    #.#L#L#.##
#'    ..L.L.....
#'    #L#L##L#L#
#'    #.LLLLLL.L
#'    #.#L#L#.##
#'    
#' At this point, something interesting happens: the chaos stabilizes and 
#' further applications of these rules cause no seats to change state! Once 
#' people stop moving around, you count 37 occupied seats.
#'    
#' Simulate your seating area by applying the seating rules repeatedly until no 
#' seats change state. How many seats end up occupied?

test_input1 <- c(
  "L.LL.LL.LL",
  "LLLLLLL.LL",
  "L.L.L..L..",
  "LLLL.LL.LL",
  "L.LL.LL.LL",
  "L.LLLLL.LL",
  "..L.L.....",
  "LLLLLLLLLL",
  "L.LLLLLL.L",
  "L.LLLLL.LL"
)

real_input <- readLines('input.txt')

# Helper function, given an input in the form of a list of individual lines
# from the input file, returns a matrix where each element of the matrix
# is an individual character from the input, padded with an additional
# row/column of '.' characters surrounding the original input.
get_seat_map <- function(input) {
  lines <- strsplit(input, '')
  seats <- do.call(rbind, lines)
  rbind('.', cbind('.', seats, '.'), '.')
}

# Helper function, given a row index, column index, and a matrix as produced
# by `get_seat_map()`, returns a 3x3 matrix containing the characters 
# from `seat_map` surrounding the index identified by `row`,`col`. The
# central character is replaced with '@' purely because it has no meaning
# to other functions.
get_neighbors <- function(row, col, seat_map) {
  neighbors <- seat_map[(row-1):(row+1), (col-1):(col+1)]
  neighbors[2, 2] <- '@'
  neighbors
}

# Helper function, given a row index, column index, `seat_map` matrix, and a
# maximum number of acceptable neighbors for a `seat_map` cell to have occupied,
# returns the next state for the matrix element indicated by `row`,`col` as
# defined by the game rules
advance_seat_state <- function(row, col, seat_map, max_neighbors = 4) {
  neighbors <- get_neighbors(row, col, seat_map)
  is_empty <- seat_map[row, col] == 'L'
  is_occupied <- seat_map[row, col] == '#'
  occupied_neighbors <- sum(neighbors == '#')
  
  if (is_empty && occupied_neighbors == 0) { return('#') }
  if (is_occupied && occupied_neighbors >= max_neighbors) { return('L') }
  return(seat_map[row, col])
}

# Helper function, given a `seat_map` matrix and a maximum number of acceptable
# neighbors for a `seat_map` cell to have occupied according to the game rules
# (4 for the initial case), iterates over the matrix, identifies the next state
# for each element, and returns a matrix consisting of the next state for each
# matrix element
advance_seat_map <- function(seat_map, max_neighbors = 4) {
  dims <- dim(seat_map)
  rows <- dims[1]
  cols <- dims[2]
  updated_seat_matrix <- matrix(data = '.', nrow = dims[1], ncol = dims[2])
  for (row in 2:rows) {
    for (col in 2:cols) {
      if (seat_map[row, col] != '.') {
        updated_seat_matrix[row, col] <- advance_seat_state(
          row, col, seat_map, max_neighbors
        )
      }
    }
  }
  updated_seat_matrix
}

# Main function, given a `seat_map` and a maximum number of acceptable
# neighbors, advances the state of the `seat_map` until it either doesn't
# change between iterations or the specified number of iterations is reached
get_final_seat_map <- function(seat_map, max_neighbors = 4) {
  timeout <- seq(1000)
  for (t in timeout) {
    cat('\r', paste0('Simulating stage:', t))
    updated_seat_map <- advance_seat_map(seat_map, max_neighbors)
    if (all(seat_map == updated_seat_map)) { return(seat_map) }
    seat_map <- updated_seat_map
  }
}

seat_map <- get_seat_map(real_input)            # Parse input
final_seat_map <- get_final_seat_map(seat_map)  # Process map to completion
answer1 <- sum(final_seat_map == '#')           # Get answer

      