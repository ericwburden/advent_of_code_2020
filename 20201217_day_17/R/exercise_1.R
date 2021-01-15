#' **--- Day 17: Conway Cubes ---**
#'   
#' As your flight slowly drifts through the sky, the Elves at the Mythical 
#' Information Bureau at the North Pole contact you. They'd like some help 
#' debugging a malfunctioning experimental energy source aboard one of their 
#' super-secret imaging satellites.
#' 
#' The experimental energy source is based on cutting-edge technology: a set of 
#' Conway Cubes contained in a pocket dimension! When you hear it's having 
#' problems, you can't help but agree to take a look.
#' 
#' The pocket dimension contains an infinite 3-dimensional grid. At every 
#' integer 3-dimensional coordinate (x,y,z), there exists a single cube which 
#' is either active or inactive.
#' 
#' In the initial state of the pocket dimension, almost all cubes start 
#' inactive. The only exception to this is a small flat region of cubes (your 
#' puzzle input); the cubes in this region start in the specified active (#) or 
#' inactive (.) state.
#' 
#' The energy source then proceeds to boot up by executing six cycles.
#' 
#' Each cube only ever considers its neighbors: any of the 26 other cubes where 
#' any of their coordinates differ by at most 1. For example, given the cube at 
#' x=1,y=2,z=3, its neighbors include the cube at x=2,y=2,z=2, the cube at 
#' x=0,y=2,z=3, and so on.
#' 
#' During a cycle, all cubes simultaneously change their state according to the 
#' following rules:
#' 
#'     If a cube is active and exactly 2 or 3 of its neighbors are also active, 
#'     the cube remains active. Otherwise, the cube becomes inactive.
#'     If a cube is inactive but exactly 3 of its neighbors are active, the 
#'     cube becomes active. Otherwise, the cube remains inactive.
#' 
#' The engineers responsible for this experimental energy source would like you 
#' to simulate the pocket dimension and determine what the configuration of 
#' cubes should be at the end of the six-cycle boot process.
#' 
#' For example, consider the following initial state:
#' 
#' .#.
#' ..#
#' ###
#' 
#' Even though the pocket dimension is 3-dimensional, this initial state 
#' represents a small 2-dimensional slice of it. (In particular, this initial 
#' state defines a 3x3x1 region of the 3-dimensional space.)
#' 
#' Simulating a few cycles from this initial state produces the following 
#' configurations, where the result of each cycle is shown layer-by-layer at 
#' each given z coordinate (and the frame of view follows the active cells in 
#' each cycle):
#' 
#' Before any cycles:
#' 
#' z=0
#' .#.
#' ..#
#' ###
#' 
#' 
#' After 1 cycle:
#' 
#' z=-1
#' #..
#' ..#
#' .#.
#' 
#' z=0
#' #.#
#' .##
#' .#.
#' 
#' z=1
#' #..
#' ..#
#' .#.
#' 
#' 
#' After 2 cycles:
#' 
#' z=-2
#' .....
#' .....
#' ..#..
#' .....
#' .....
#' 
#' z=-1
#' ..#..
#' .#..#
#' ....#
#' .#...
#' .....
#' 
#' z=0
#' ##...
#' ##...
#' #....
#' ....#
#' .###.
#' 
#' z=1
#' ..#..
#' .#..#
#' ....#
#' .#...
#' .....
#' 
#' z=2
#' .....
#' .....
#' ..#..
#' .....
#' .....
#' 
#' 
#' After 3 cycles:
#' 
#' z=-2
#' .......
#' .......
#' ..##...
#' ..###..
#' .......
#' .......
#' .......
#' 
#' z=-1
#' ..#....
#' ...#...
#' #......
#' .....##
#' .#...#.
#' ..#.#..
#' ...#...
#' 
#' z=0
#' ...#...
#' .......
#' #......
#' .......
#' .....##
#' .##.#..
#' ...#...
#' 
#' z=1
#' ..#....
#' ...#...
#' #......
#' .....##
#' .#...#.
#' ..#.#..
#' ...#...
#' 
#' z=2
#' .......
#' .......
#' ..##...
#' ..###..
#' .......
#' .......
#' .......
#' 
#' After the full six-cycle boot process completes, 112 cubes are left in the 
#' active state.
#' 
#' Starting with your given initial configuration, simulate six cycles. How 
#' many cubes are left in the active state after the sixth cycle?

# The future/future.apply packages provide access to multiple R worker processes
# to speed up apply-type operations through the use of future_*apply functions.
library(future)
library(future.apply)
plan(multisession, workers = 6)

test_input <- c(
  ".#.",
  "..#",
  "###"
)
real_input <- readLines('../input.txt')

# Given a set of input lines representing a 'slice' of a 3d space `input`, 
# returns a three-dimensional array containing that slice
initialize_cube <- function(input) {
  dim1 <- length(input)
  dim2 <- nchar(input[[1]])
  input_matrix <- matrix(unlist(strsplit(input, '')), dim1, dim2, TRUE)
  new_cube <- array('.', c(dim1, dim2, 1))
  new_cube[1:dim1, 1:dim2, 1] <- input_matrix
  new_cube
}


# Given a three-dimensional array `cube`, expands the array by one index in all
# directions, filling the new spaces with the '.' character
grow_cube <- function(cube) {
  d <- dim(cube)
  new_cube <- array('.', d + 2)
  
  new_cube[seq(d[1])+1, seq(d[2])+1, seq(d[3])+1] <- cube
  new_cube
}


# Given the x, y, and z coordinates of an element in a three-dimensional array
# (`d1`, `d2`, and `d3`, respectively) and the three-dimensional array `cube`, 
# returns a sub-array containing the elements immediately adjacent to the 
# indicated coordinate in all dimensions. The central element, defined by the
# indicated coordinate, is replaced by an empty string.
get_neighbors <- function(d1, d2, d3, cube) {
  d <- dim(cube)
  d1_range <- max(1, d1-1):min(d1+1, d[1])
  d2_range <- max(1, d2-1):min(d2+1, d[2])
  d3_range <- max(1, d3-1):min(d3+1, d[3])
  cube[d1, d2, d3] <- ''
  neighbor_slice <- cube[d1_range, d2_range, d3_range]
  neighbor_slice
}


# Given a three-dimensional array `cube`, returns the elements that comprise the
# 'shell' of that array, that is, the elements on the outer edges of the array
# in all dimensions. Elements along the interface between the dimensions are
# included multiple times.
get_shell <- function(cube) {
  d <- dim(cube)
  d1_edge_cells <- cube[c(1, d[1]), ,  ]
  d2_edge_cells <- cube[ , c(1, d[2]), ]
  d3_edge_cells <- cube[ , , c(1, d[3])]
  c(d1_edge_cells, d2_edge_cells, d3_edge_cells)
}


# Given a single numeric index to a three-dimensional array element `index` and
# the three-dimensional array `cube`, returns the value of that element after
# applying the rules for modifying an element per the puzzle instructions
next_cell_state <- function(index, cube) {
  # Convert the single number index to an array index
  arr_indices <- which(slice.index(cube, c(1, 2, 3)) == index, arr.ind = TRUE)
  
  # Split the array index into `d1`, `d2`, and `d3`
  d1 <- arr_indices[,1]; d2 <- arr_indices[,2]; d3 <- arr_indices[,3]
  neighbors <- get_neighbors(d1, d2, d3, cube)  # Get neighbors
  is_active <- cube[d1, d2, d3] == '#'          # Current cell is active?
  active_neighbors <- sum(neighbors == '#')     # Count active numbers
  
  # Apply the rules for changing the value of the index
  if (is_active && active_neighbors %in% c(2, 3)) { return('#') }
  if (!is_active && active_neighbors == 3) { return('#') }
  return('.')
}


# Given a three-dimensional array `cube`, iterate through the array and return
# an array containing the next state of each element. If the 'shell' of the
# cube contains any '#', expands the cube one unit in each dimension before
# returning it.
next_cube_state <- function(cube) {
  
  # Applies the `next_cell_state()` function to each element in the `cube`
  next_cube <- future_apply(
    slice.index(cube, c(1, 2, 3)), 
    c(1, 2, 3), 
    next_cell_state, 
    cube
  )
  
  # Expands the cube if any exterior element == '#'
  if (any(get_shell(next_cube) == '#')) { next_cube <- grow_cube(next_cube) }
  next_cube
}

new_cube <- initialize_cube(real_input)  # Start up the cube
next_cube <- grow_cube(new_cube)         # Expand one time for good measure
for (i in 1:6) {  next_cube <- next_cube_state(next_cube) }  # Six generations
answer1 <- sum(next_cube == '#')  # Count the '#''s

# Answer: 380
