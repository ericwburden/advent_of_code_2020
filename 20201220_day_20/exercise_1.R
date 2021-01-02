# --- Day 20: Jurassic Jigsaw ---
#   
# The high-speed train leaves the forest and quickly carries you south. You can 
# even see a desert in the distance! Since you have some spare time, you might 
# as well see if there was anything interesting in the image the Mythical 
# Information Bureau satellite captured.
# 
# After decoding the satellite messages, you discover that the data actually 
# contains many small images created by the satellite's camera array. The 
# camera array consists of many cameras; rather than produce a single square 
# image, they produce many smaller square image tiles that need to be 
# reassembled back into a single image.
# 
# Each camera in the camera array returns a single monochrome image tile with a 
# random unique ID number. The tiles (your puzzle input) arrived in a random 
# order.
# 
# Worse yet, the camera array appears to be malfunctioning: each image tile has 
# been rotated and flipped to a random orientation. Your first task is to 
# reassemble the original image by orienting the tiles so they fit together.
# 
# To show how the tiles should be reassembled, each tile's image data includes 
# a border that should line up exactly with its adjacent tiles. All tiles have 
# this border, and the border lines up exactly when the tiles are both 
# oriented correctly. Tiles at the edge of the image also have this border, 
# but the outermost edges won't line up with any other tiles.
# 
# For example, suppose you have the following nine tiles:
# 
# Tile 2311:
# ..##.#..#.
# ##..#.....
# #...##..#.
# ####.#...#
# ##.##.###.
# ##...#.###
# .#.#.#..##
# ..#....#..
# ###...#.#.
# ..###..###
# 
# Tile 1951:
# #.##...##.
# #.####...#
# .....#..##
# #...######
# .##.#....#
# .###.#####
# ###.##.##.
# .###....#.
# ..#.#..#.#
# #...##.#..
# 
# Tile 1171:
# ####...##.
# #..##.#..#
# ##.#..#.#.
# .###.####.
# ..###.####
# .##....##.
# .#...####.
# #.##.####.
# ####..#...
# .....##...
# 
# Tile 1427:
# ###.##.#..
# .#..#.##..
# .#.##.#..#
# #.#.#.##.#
# ....#...##
# ...##..##.
# ...#.#####
# .#.####.#.
# ..#..###.#
# ..##.#..#.
# 
# Tile 1489:
# ##.#.#....
# ..##...#..
# .##..##...
# ..#...#...
# #####...#.
# #..#.#.#.#
# ...#.#.#..
# ##.#...##.
# ..##.##.##
# ###.##.#..
# 
# Tile 2473:
# #....####.
# #..#.##...
# #.##..#...
# ######.#.#
# .#...#.#.#
# .#########
# .###.#..#.
# ########.#
# ##...##.#.
# ..###.#.#.
# 
# Tile 2971:
# ..#.#....#
# #...###...
# #.#.###...
# ##.##..#..
# .#####..##
# .#..####.#
# #..#.#..#.
# ..####.###
# ..#.#.###.
# ...#.#.#.#
# 
# Tile 2729:
# ...#.#.#.#
# ####.#....
# ..#.#.....
# ....#..#.#
# .##..##.#.
# .#.####...
# ####.#.#..
# ##.####...
# ##..#.##..
# #.##...##.
# 
# Tile 3079:
# #.#.#####.
# .#..######
# ..#.......
# ######....
# ####.#..#.
# .#...#.##.
# #.#####.##
# ..#.###...
# ..#.......
# ..#.###...
# 
# By rotating, flipping, and rearranging them, you can find a square 
# arrangement that causes all adjacent borders to line up:
# 
# #...##.#.. ..###..### #.#.#####.
# ..#.#..#.# ###...#.#. .#..######
# .###....#. ..#....#.. ..#.......
# ###.##.##. .#.#.#..## ######....
# .###.##### ##...#.### ####.#..#.
# .##.#....# ##.##.###. .#...#.##.
# #...###### ####.#...# #.#####.##
# .....#..## #...##..#. ..#.###...
# #.####...# ##..#..... ..#.......
# #.##...##. ..##.#..#. ..#.###...
# 
# #.##...##. ..##.#..#. ..#.###...
# ##..#.##.. ..#..###.# ##.##....#
# ##.####... .#.####.#. ..#.###..#
# ####.#.#.. ...#.##### ###.#..###
# .#.####... ...##..##. .######.##
# .##..##.#. ....#...## #.#.#.#...
# ....#..#.# #.#.#.##.# #.###.###.
# ..#.#..... .#.##.#..# #.###.##..
# ####.#.... .#..#.##.. .######...
# ...#.#.#.# ###.##.#.. .##...####
# 
# ...#.#.#.# ###.##.#.. .##...####
# ..#.#.###. ..##.##.## #..#.##..#
# ..####.### ##.#...##. .#.#..#.##
# #..#.#..#. ...#.#.#.. .####.###.
# .#..####.# #..#.#.#.# ####.###..
# .#####..## #####...#. .##....##.
# ##.##..#.. ..#...#... .####...#.
# #.#.###... .##..##... .####.##.#
# #...###... ..##...#.. ...#..####
# ..#.#....# ##.#.#.... ...##.....
# 
# For reference, the IDs of the above tiles are:
# 
# 1951    2311    3079
# 2729    1427    2473
# 2971    1489    1171
# 
# To check that you've assembled the image correctly, multiply the IDs of the 
# four corner tiles together. If you do this with the assembled tiles from the 
# example above, you get 1951 * 3079 * 2971 * 1171 = 20899048083289.
# 
# Assemble the tiles into an image. What do you get if you multiply together 
# the IDs of the four corner tiles?

# Input ------------------------------------------------------------------------

test_input <- readLines('test_input.txt')
real_input <- readLines('input.txt')


# Functions --------------------------------------------------------------------

# Helper function, parses the input lines into a list of 'tiles', lists 
# containing a name and a matrix of characters representing image contents
input_to_tiles <- function(input) {
  current_tile <- 0  # Index of the tile to add lines to
  tiles <- list()    # Empty list for tiles
  
  # For each line in the input file...
  for (line in input) {
    if (line =='') { next }  # Skip blank lines
    
    # If the line contains a tile title, add an empty character vector
    # to `tiles` named according to the tile id
    if (grepl('Tile \\d+:', line)) {
      current_tile <- current_tile + 1
      current_tile_name <- regmatches(line, regexpr('\\d+', line))
      tiles[[current_tile_name]]$name <- current_tile_name
      tiles[[current_tile_name]]$tile <- character(0)
      next
    }
    
    # For all other lines, split the line into characters and add it to
    # the `tiles` list to the tile currently being added to
    tiles[[current_tile_name]]$tile <- c(
      tiles[[current_tile_name]]$tile, 
      strsplit(line, '')
    )
  }
  
  # Convert each element in the tiles list to a matrix
  for (tile_name in names(tiles)) {
    tiles[[tile_name]]$tile <- do.call(rbind, tiles[[tile_name]]$tile )
  }
  tiles
}

# Helper function, rotates a matrix 90' clockwise
rotate <- function(tile_tile) {
  t(apply(tile_tile, 2, rev))
}

# Helper function, flips a matrix vertically
flip <- function(tile_tile) {
  apply(tile_tile, 2, rev)
}

# Helper function, given a string indicating a side of a tile matrix `side` and
# the tile matrix, returns the characters that make up that side of the tile
# matrix
get_side <- function(side, tile) {
  if (side == 'top') { 
    tile$tile[1,] 
  } else if (side == 'right') { 
    tile$tile[, ncol(tile$tile)] 
  } else if (side == 'bottom') { 
    tile$tile[nrow(tile$tile),] 
  } else if (side == 'left') { 
    tile$tile[,1] 
  } else {
    stop(paste(side, 'is not a valid argument for `side`'))
  }
}

# Helper function, given a pattern from the side of a tile matrix `pattern`, a
# string indicating which side it came from `side`, and a tile to test that
# pattern against `test_tile`, flip and rotate the `test_tile` into the 
# orientation that matches the pattern for the given side. Return the 
# `test_tile` in the identified orientation if it can be achieved. Otherwise, 
# return NULL. Note, `side` here references the base tile being matched against, 
# not the `test_tile`. A 'right' `side` will match the `test_tile`'s left-hand 
# side, for example.
check_tile_match <- function(pattern, side, test_tile) {
  
  # For each possible permutation of `test_tile`...
  for (i in 1:8) {
    
    # Get the side pattern from the appropriate side of the `test_tile` to 
    # compare to `pattern`
    test_pattern <- if (side == 'top') { 
      get_side('bottom', test_tile) 
    } else if (side == 'right') { 
      get_side('left', test_tile) 
    } else if (side == 'bottom') { 
      get_side('top', test_tile)
    } else if (side == 'left') { 
      get_side('right', test_tile) 
    } else {
      stop(paste(side, 'is not a valid argument for `side`'))
    }
    
    # If they match, return the test tile. Otherwise, flip/rotate the 
    # `test_tile` and try again. Flip on the 5th try, rotate on all others
    if (identical(pattern, test_pattern)) { return(test_tile) }
    test_tile$tile <- if (i == 5) { flip(test_tile$tile) } else { rotate(test_tile$tile) }
  }
}

# Helper function, given a tile `base_tile`, a string indicating which side of
# the base tile to match on `side`, and a set of tiles to search for a match
# `tiles`, flip and rotate the tiles in `tiles` to find the one that matches
# side `side` of `base_tile`. If one is found, return it in the matching
# orientation, otherwise return NULL
match_side <- function(base_tile, side, tiles) {
  side_pattern <- get_side(side, base_tile)
  for (test_tile in tiles) {
    test_result <- check_tile_match(side_pattern, side, test_tile)
    if (!is.null(test_result)) { return(test_result) }
  }
}


# Processing ------------------------------------------------------------------

unmatched_tiles <- input_to_tiles(real_input)  # All tiles, to start
tile_count <- length(unmatched_tiles)          # How many tiles?
matched_tiles <- list()                        # Move tiles here once matched

# Move the first tile in `unmatched_tiles` to the `matched_tiles` list
matched_tiles[[unmatched_tiles[[1]]$name]] <- unmatched_tiles[[1]]
unmatched_tiles[1] <- NULL

# The matrix used for arranging the tiles must be large enough that any square
# containing `tile_count` elements starting from the center index cannot exceed
# the bounds of the matrix.
map_dim <- (sqrt(tile_count) * 2) + 1          
tile_arrangement <- matrix(NA, ncol = map_dim, nrow = map_dim)

# Put the one tile in `matched_tiles` into the center of the `tile_arrangement`
# matrix. We will add the other tiles to it, sort of like domino's.
tile_arrangement[((map_dim %/% 2)+1), ((map_dim %/% 2)+1)] <- matched_tiles[[1]]$name

# Single number indices for the `tile_arrangement` matrix
arrangement_indices <- slice.index(tile_arrangement, c(1, 2))


# Until all the tiles have been moved from `unmatched_tiles` to `matched_tiles`...
checked_indices <- numeric(0)
while (length(unmatched_tiles) > 0) {
  
  # Get the indices for all the tiles that have been added to `tile_arrangement`,
  # except for the ones that have been matched against already. Each iteration,
  # this will yield the newly matched tile indices
  occupied_indices <- arrangement_indices[!is.na(tile_arrangement)]
  indices_to_check <- setdiff(occupied_indices, checked_indices)
  
  # For each newly added tile...
  for (i in indices_to_check) {
    
    # Get the array index from the single number index
    arr_ind <- which(arrangement_indices == i, arr.ind = T)
    current_tile <- matched_tiles[[tile_arrangement[i]]]  # Tile to match against
    
    # For each side of the tile to match against...
    for (side in c('top', 'right', 'bottom', 'left')) {
      
      # Calculate the index for the space to the top, right, bottom, or left
      # of the tile being matched against
      target_ind <- if (side == 'top') { 
        arr_ind + c(-1, 0) 
      } else if (side == 'right') { 
        arr_ind + c(0, 1) 
      } else if (side == 'bottom') { 
        arr_ind + c(1, 0) 
      } else if (side == 'left') { 
        arr_ind + c(0, -1) 
      }
      
      # If there's not already a tile in that space...
      if (is.na(tile_arrangement[target_ind[1], target_ind[2]])) {
        
        # Check if there is an unmatched tile that could fit in that space. If
        # so, move that tile from `unmatched_tiles` to `matched_tiles`, and add
        # its name to `tile_arrangement` in the appropriate position
        matching_tile <- match_side(current_tile, side, unmatched_tiles)
        if (!is.null(matching_tile)) {
          unmatched_tiles[[matching_tile$name]] <- NULL
          matched_tiles[[matching_tile$name]] <- matching_tile
          tile_arrangement[target_ind[1], target_ind[2]] <- matching_tile$name
        }
      }
    }
    
    # Keep up with checked indices to avoid trying to match against the same
    # tile again
    checked_indices <- c(checked_indices, i) 
  }
}

# Get the spaces in `tile_arrangement` that have tile names in them, 'crop' 
# `tile_arrangement` to just those indices, get the tile name (id) from each
# corner, and multiply them together.
occupied_indices <- arrangement_indices[!is.na(tile_arrangement)]
tiles_dim <- sqrt(tile_count)
cropped_arrangement <- matrix(tile_arrangement[occupied_indices], nrow = tiles_dim)
corners <- c(
  cropped_arrangement[1, 1], 
  cropped_arrangement[1, tiles_dim], 
  cropped_arrangement[tiles_dim, 1], 
  cropped_arrangement[tiles_dim, tiles_dim]
)
answer1 <- prod(as.numeric(corners))

# Answer: 7492183537913







