#' **--- Part Two ---**
#'   
#' As soon as people start to arrive, you realize your mistake. People don't 
#' just care about adjacent seats - they care about the first seat they can see 
#' in each of those eight directions!
#' 
#' Now, instead of considering just the eight immediately adjacent seats, 
#' consider the first seat in each of those eight directions. For example, 
#' the empty seat below would see eight occupied seats:
#' 
#' .......#.
#' ...#.....
#' .#.......
#' .........
#' ..#L....#
#' ....#....
#' .........
#' #........
#' ...#.....
#' 
#' The leftmost empty seat below would only see one empty seat, but cannot see 
#' any of the occupied ones:
#' 
#' .............
#' .L.L.#.#.#.#.
#' .............
#' 
#' The empty seat below would see no occupied seats:
#' 
#' .##.##.
#' #.#.#.#
#' ##...##
#' ...L...
#' ##...##
#' #.#.#.#
#' .##.##.
#' 
#' Also, people seem to be more tolerant than you expected: it now takes five 
#' or more visible occupied seats for an occupied seat to become empty (rather 
#' than four or more from the previous rules). The other rules still apply: 
#' empty seats that see no occupied seats become occupied, seats matching no 
#' rule don't change, and floor never changes.
#' 
#' Given the same starting layout as above, these new rules cause the seating 
#' area to shift around as follows:
#'   
#' L.LL.LL.LL
#' LLLLLLL.LL
#' L.L.L..L..
#' LLLL.LL.LL
#' L.LL.LL.LL
#' L.LLLLL.LL
#' ..L.L.....
#' LLLLLLLLLL
#' L.LLLLLL.L
#' L.LLLLL.LL
#' 
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
#' 
#' #.LL.LL.L#
#' #LLLLLL.LL
#' L.L.L..L..
#' LLLL.LL.LL
#' L.LL.LL.LL
#' L.LLLLL.LL
#' ..L.L.....
#' LLLLLLLLL#
#' #.LLLLLL.L
#' #.LLLLL.L#
#' 
#' #.L#.##.L#
#' #L#####.LL
#' L.#.#..#..
#' ##L#.##.##
#' #.##.#L.##
#' #.#####.#L
#' ..#.#.....
#' LLL####LL#
#' #.L#####.L
#' #.L####.L#
#' 
#' #.L#.L#.L#
#' #LLLLLL.LL
#' L.L.L..#..
#' ##LL.LL.L#
#' L.LL.LL.L#
#' #.LLLLL.LL
#' ..L.L.....
#' LLLLLLLLL#
#' #.LLLLL#.L
#' #.L#LL#.L#
#' 
#' #.L#.L#.L#
#' #LLLLLL.LL
#' L.L.L..#..
#' ##L#.#L.L#
#' L.L#.#L.L#
#' #.L####.LL
#' ..#.#.....
#' LLL###LLL#
#' #.LLLLL#.L
#' #.L#LL#.L#
#' 
#' #.L#.L#.L#
#' #LLLLLL.LL
#' L.L.L..#..
#' ##L#.#L.L#
#' L.L#.LL.L#
#' #.LLLL#.LL
#' ..#.L.....
#' LLL###LLL#
#' #.LLLLL#.L
#' #.L#LL#.L#
#' 
#' Again, at this point, people stop shifting around and the seating area 
#' reaches equilibrium. Once this occurs, you count 26 occupied seats.
#' 
#' Given the new visibility method and the rule change for occupied seats 
#' becoming empty, once equilibrium is reached, how many seats end up occupied?

source('exercise_1.R')

# Modified helper function, given a row index, column index, and matrix of seat
# characters, return the first non-'.' character in each direction from the
# index indicated by `seat_map[row, col]`.
get_neighbors <- function(row, col, seat_map) {
  dims <- dim(seat_map)
  rows <- dims[1]
  cols <- dims[2]
  
  # List of steps to take in (row, col) format required to move the cursor in
  # each of eight directions
  directions <- list(
    left =  c(0, -1), up_left =    c(-1, -1),
    up =    c(-1, 0), up_right =   c(-1, 1),
    right = c(0, 1),  down_right = c(1, 1),
    down =  c(1, 0),  down_left =  c(1, -1)
  )
  
  # For each of eight directions, take the value of the matrix at that direction
  # repeatedly, moving one step in that same direction each iteration. Continues
  # until either a non-'.' character is found or the cursor hits the edge of the
  # matrix.
  neighbors <- vector('character', 8)
  for (direction in directions) {
    curr_row <- row
    curr_col <- col
    neighbor <- '.'
    while (
      neighbor == '.' && 
      curr_row > 1 && curr_row < rows && 
      curr_col > 1 && curr_col < cols
    ) {
      curr_row <- curr_row + direction[1]
      curr_col <- curr_col + direction[2]
      neighbor <- seat_map[curr_row, curr_col]
    }
    
    # Add to the first empty spot in the neighbors vector
    neighbors[min(which(neighbors == ""))] <- neighbor  
  }
  neighbors
}

seat_map <- get_seat_map(real_input)               # Parse input
final_seat_map <- get_final_seat_map(seat_map, 5)  # Process map to completion
answer2 <- sum(final_seat_map == '#')              # Get answer
  