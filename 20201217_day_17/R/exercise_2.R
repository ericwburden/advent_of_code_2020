#' **--- Part Two ---**
#'   
#' For some reason, your simulated results don't match what the experimental 
#' energy source engineers expected. Apparently, the pocket dimension actually 
#' has four spatial dimensions, not three.
#' 
#' The pocket dimension contains an infinite 4-dimensional grid. At every 
#' integer 4-dimensional coordinate (x,y,z,w), there exists a single hcube 
#' (really, a hyperhcube) which is still either active or inactive.
#' 
#' Each hcube only ever considers its neighbors: any of the 80 other hcubes where 
#' any of their coordinates differ by at most 1. For example, given the hcube 
#' at x=1,y=2,z=3,w=4, its neighbors include the hcube at x=2,y=2,z=3,w=3, the 
#' hcube at x=0,y=2,z=3,w=4, and so on.
#' 
#' The initial state of the pocket dimension still consists of a small flat 
#' region of hcubes. Furthermore, the same rules for cycle updating still apply: 
#' during each cycle, consider the number of active neighbors of each hcube.
#' 
#' For example, consider the same initial state as in the example above. Even 
#' though the pocket dimension is 4-dimensional, this initial state represents 
#' a small 2-dimensional slice of it. (In particular, this initial state 
#' defines a 3x3x1x1 region of the 4-dimensional space.)
#' 
#' Simulating a few cycles from this initial state produces the following 
#' configurations, where the result of each cycle is shown layer-by-layer at 
#' each given z and w coordinate:
#' 
#' Before any cycles:
#' 
#' z=0, w=0
#' .#.
#' ..#
#' ###
#' 
#' 
#' After 1 cycle:
#' 
#' z=-1, w=-1
#' #..
#' ..#
#' .#.
#' 
#' z=0, w=-1
#' #..
#' ..#
#' .#.
#' 
#' z=1, w=-1
#' #..
#' ..#
#' .#.
#' 
#' z=-1, w=0
#' #..
#' ..#
#' .#.
#' 
#' z=0, w=0
#' #.#
#' .##
#' .#.
#' 
#' z=1, w=0
#' #..
#' ..#
#' .#.
#' 
#' z=-1, w=1
#' #..
#' ..#
#' .#.
#' 
#' z=0, w=1
#' #..
#' ..#
#' .#.
#' 
#' z=1, w=1
#' #..
#' ..#
#' .#.
#' 
#' 
#' After 2 cycles:
#' 
#' z=-2, w=-2
#' .....
#' .....
#' ..#..
#' .....
#' .....
#' 
#' z=-1, w=-2
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=0, w=-2
#' ###..
#' ##.##
#' #...#
#' .#..#
#' .###.
#' 
#' z=1, w=-2
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=2, w=-2
#' .....
#' .....
#' ..#..
#' .....
#' .....
#' 
#' z=-2, w=-1
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=-1, w=-1
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=0, w=-1
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=1, w=-1
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=2, w=-1
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=-2, w=0
#' ###..
#' ##.##
#' #...#
#' .#..#
#' .###.
#' 
#' z=-1, w=0
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=0, w=0
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=1, w=0
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=2, w=0
#' ###..
#' ##.##
#' #...#
#' .#..#
#' .###.
#' 
#' z=-2, w=1
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=-1, w=1
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=0, w=1
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=1, w=1
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=2, w=1
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=-2, w=2
#' .....
#' .....
#' ..#..
#' .....
#' .....
#' 
#' z=-1, w=2
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=0, w=2
#' ###..
#' ##.##
#' #...#
#' .#..#
#' .###.
#' 
#' z=1, w=2
#' .....
#' .....
#' .....
#' .....
#' .....
#' 
#' z=2, w=2
#' .....
#' .....
#' ..#..
#' .....
#' .....
#' 
#' After the full six-cycle boot process completes, 848 hcubes are left in the 
#' active state.
#' 
#' Starting with your given initial configuration, simulate six cycles in a 
#' 4-dimensional space. How many hcubes are left in the active state after the 
#' sixth cycle?

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


# Given a set of input lines representing a 'slice' of a 4d space `input`, 
# returns a *four*-dimensional array containing that slice
initialize_hcube <- function(input) {
  dim1 <- length(input)
  dim2 <- nchar(input[[1]])
  input_matrix <- matrix(unlist(strsplit(input, '')), dim1, dim2, TRUE)
  new_hcube <- array('.', c(dim1, dim2, 1, 1))
  new_hcube[1:dim1, 1:dim2, 1, 1] <- input_matrix
  new_hcube
}


# Given a *four*-dimensional array `hcube`, expands the array by one index in all
# directions, filling the new spaces with the '.' character
grow_hcube <- function(hcube) {
  d <- dim(hcube)
  new_hcube <- array('.', d + 2)
  
  new_hcube[seq(d[1])+1, seq(d[2])+1, seq(d[3])+1, seq(d[4])+1] <- hcube
  new_hcube
}


# Given the x, y, and z coordinates of an element in a *four*-dimensional array
# (`d1`, `d2`, `d3`, and `d4`, respectively) and the *four*-dimensional array `hcube`, 
# returns a sub-array containing the elements immediately adjacent to the 
# indicated coordinate in all dimensions. The central element, defined by the
# indicated coordinate, is replaced by an empty string.
get_neighbors <- function(d1, d2, d3, d4, hcube) {
  d <- dim(hcube)
  d1_range <- max(1, d1-1):min(d1+1, d[1])
  d2_range <- max(1, d2-1):min(d2+1, d[2])
  d3_range <- max(1, d3-1):min(d3+1, d[3])
  d4_range <- max(1, d4-1):min(d4+1, d[4])
  hcube[d1, d2, d3, d4] <- ''
  neighbor_slice <- hcube[d1_range, d2_range, d3_range, d4_range]
  neighbor_slice
}


# Given a *four*-dimensional array `hcube`, returns the elements that comprise the
# 'shell' of that array, that is, the elements on the outer edges of the array
# in all dimensions. Elements along the interface between the dimensions are
# included multiple times.
get_shell <- function(hcube) {
  d <- dim(hcube)
  d1_edge_cells <- hcube[c(1, d[1]), , ,  ]
  d2_edge_cells <- hcube[ , c(1, d[2]), , ]
  d3_edge_cells <- hcube[ , , c(1, d[3]), ]
  d4_edge_cells <- hcube[ , , , c(1, d[4])]
  c(d1_edge_cells, d2_edge_cells, d3_edge_cells, d4_edge_cells)
}


# Given a single numeric index to a *four*-dimensional array element `index` and
# the *four*-dimensional array `hcube`, returns the value of that element after
# applying the rules for modifying an element per the puzzle instructions
next_cell_state <- function(index, hcube) {
  arr_indices <- which(slice.index(hcube, c(1, 2, 3, 4)) == index, arr.ind = TRUE)
  d1 <- arr_indices[,1]; d2 <- arr_indices[,2]; d3 <- arr_indices[,3]; d4 <- arr_indices[,4]
  neighbors <- get_neighbors(d1, d2, d3, d4, hcube)
  is_active <- hcube[d1, d2, d3, d4] == '#'
  active_neighbors <- sum(neighbors == '#')
  
  if (is_active && active_neighbors %in% c(2, 3)) { return('#') }
  if (!is_active && active_neighbors == 3) { return('#') }
  return('.')
}


# Given a *four*-dimensional array `hcube`, iterate through the array and return
# an array containing the next state of each element. If the 'shell' of the
# hcube contains any '#', expands the hcube one unit in each dimension before
# returning it.
next_hcube_state <- function(hcube) {
  next_hcube <- future_apply(
    slice.index(hcube, c(1, 2, 3, 4)), 
    c(1, 2, 3, 4), 
    next_cell_state, 
    hcube
  )
  if (any(get_shell(next_hcube) == '#')) { next_hcube <- grow_hcube(next_hcube) }
  next_hcube
}

new_hcube <- initialize_hcube(real_input)  # Start up the hcube
next_hcube <- grow_hcube(new_hcube)        # Expand one time for good measure
for (i in 1:6) {                           # Six generations
  cat('\r', paste('Simulating hcube state:', i))
  next_hcube <- next_hcube_state(next_hcube) 
}
answer2 <- sum(next_hcube == '#')          # Count the '#''s

# Answer: 2332
