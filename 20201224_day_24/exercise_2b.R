# --- Part Two ---
#   
# The tile floor in the lobby is meant to be a living art exhibit. Every day, 
# the tiles are all flipped according to the following rules:
#   
# Any black tile with zero or more than 2 black tiles immediately adjacent to 
# it is flipped to white.
# Any white tile with exactly 2 black tiles immediately adjacent to it is 
# flipped to black.
# 
# Here, tiles immediately adjacent means the six tiles directly touching the 
# tile in question.
# 
# The rules are applied simultaneously to every tile; put another way, it is 
# first determined which tiles need to be flipped, then they are all flipped at 
# the same time.
# 
# In the above example, the number of black tiles that are facing up after the 
# given number of days has passed is as follows:
#   
# Day 1: 15
# Day 2: 12
# Day 3: 25
# Day 4: 14
# Day 5: 23
# Day 6: 28
# Day 7: 41
# Day 8: 37
# Day 9: 49
# Day 10: 37
# 
# Day 20: 132
# Day 30: 259
# Day 40: 406
# Day 50: 566
# Day 60: 788
# Day 70: 1106
# Day 80: 1373
# Day 90: 1844
# Day 100: 2208
# 
# After executing this process a total of 100 times, there would be 2208 black 
# tiles facing up.
# 
# How many tiles will be black after 100 days?

# Setup ------------------------------------------------------------------------

source('exercise_1b.R')


# Functions --------------------------------------------------------------------

# Given a vector indicating the x/y/z coordinates of a tile `tile_loc` and a
# data frame of tile locations and colors `tile_table`, return the color of
# the tile on the row indicated by `tile_loc`
get_tile_color <- function(tile_loc, tile_table) {
  selector <- (
    tile_table$x == tile_loc[1] &
      tile_table$y == tile_loc[2] &
      tile_table$z == tile_loc[3]
  )
  tile_table[selector, 'color']
}


# Given a vector indicating the x/y/z coordinates of a tile `tile_loc` and a
# data frame of tile locations and colors `tile_table`, returns a list of 
# coordinates for neighboring tiles
get_neighbors <- function(tile_loc, tile_table) {
  neighbor_offsets <- list(
    c(0,  1, -1), c( 1, 0, -1), c( 1, -1, 0),
    c(0, -1,  1), c(-1, 0,  1), c(-1,  1, 0)
  )
  lapply(neighbor_offsets, `+`, tile_loc)
}


# Given a vector indicating the x/y/z coordinates of a tile `tile_loc` and a
# data frame of tile locations and colors `tile_table`, return a vector of the
# colors of the neighboring tiles
get_neighbor_colors <- function(tile_loc, tile_table) {
  neighbor_indices <- get_neighbors(tile_loc, tile_table)
  neighbor_colors <- sapply(neighbor_indices, get_tile_color, tile_table)
  neighbor_colors
}


# Given a vector indicating the x/y/z coordinates of a tile `tile_loc` and a
# data frame of tile locations and colors `tile_table`, return the next color
# of the indicated tile according to the rules of the puzzle
next_tile_color <- function(tile_loc, tile_table) {
  tile_color <- get_tile_color(tile_loc, tile_table)  # Current tile color
  
  # Colors of the neighboring tiles
  neighbor_colors <- get_neighbor_colors(tile_loc, tile_table)
  black_neighbors <- sum(neighbor_colors == 'black', na.rm = T)  # Count black neighbors

  # Should the tile be flipped?
  flip <- if (tile_color == 'black') {
    black_neighbors == 0 | black_neighbors > 2
  } else if (tile_color == 'white') {
    black_neighbors == 2
  } else {
    stop(paste('Could not get a color for tile: ', tile_loc))
  }
  
  # The final tile color
  if (flip & tile_color == 'white') { 
    'black'
  } else if (flip & tile_color == 'black') {
    'white'
  } else {
    tile_color
  }
}


# Given a vector indicating the x/y/z coordinates of a tile `tile_loc` and a
# data frame of tile locations and colors `tile_table`, add rows to the 
# `tile_table` to ensure that the `tile_table` contains records for all the
# tiles neighboring `tile_loc`
add_neighbors <- function(tile_loc, tile_table) {
  neighbor_indices <- get_neighbors(tile_loc, tile_table)  # Locations of neighbors
  
  # For each neighbor index...
  for (ni in neighbor_indices) {
    
    # Define a selector for the row at the index
    ni <- as.numeric(ni)
    selector <- (
      tile_table$x == ni[1] &
        tile_table$y == ni[2] &
        tile_table$z == ni[3]
    )
    
    # If there's no row at that index, add one
    if (nrow(tile_table[selector,]) < 1) {
      new_row <- data.frame(
        x = ni[1], y = ni[2], z = ni[3], 
        color = 'white', all_neighbors = FALSE,
        stringsAsFactors = F
      )
      tile_table <- rbind(tile_table, new_row)
    }
  }
  
  # Indicate in the 'all_neighbors' column that all the neighbors for this
  # tile are represented in the table
  tile_table[
    tile_table$x == tile_loc[1] &
    tile_table$y == tile_loc[2] &
    tile_table$z == tile_loc[3],
    'all_neighbors'
  ] <- TRUE
  
  tile_table  # Return the `tile_table`
}

# Given a data frame of tile locations and colors `tile_table`, iterate through
# the black tiles and ensure those tiles all have their neighbors represented
# in the table
expand_table <- function(tile_table) {
  
  # Select the coordinates from all the `tile_table` rows representing black 
  # tiles where we haven't yet confirmed all the neighbors for that  tile are
  # in the `tile_table`
  black_tile_locs <- tile_table[
    (tile_table$color == 'black' & !tile_table$all_neighbors), 
    c('x', 'y', 'z')
  ]
  num_black_tiles <- nrow(black_tile_locs)  # The number of tiles to check
  
  # For each black tile to be checked...
  for (btl in split(black_tile_locs, 1:num_black_tiles)) {
    tile_table <- add_neighbors(btl, tile_table)  # Add all its neighbors
  }
  tile_table  # Return the `tile_table`
}


# Given a data frame of tile locations and colors `tile_table`, return the 
# colors for each row in the data frame representing the next state of each
# tile according to the instructions
next_table_colors <- function(tile_table) {
  apply(tile_table[,c('x', 'y', 'z')], 1, next_tile_color, tile_table)
}


# Processing -------------------------------------------------------------------

tile_table$all_neighbors <- FALSE  # Set the `all_neighbors` column to FALSE

# Advance the floor state 100 times, starting with the floor state at the end
# of part one.
rounds <- 100
pb <- txtProgressBar(min = 0, max = rounds, style = 3)
for (i in 1:rounds) {
  tile_table <- expand_table(tile_table)       # Ensure all black tiles have neighbors
  new_colors <- next_table_colors(tile_table)  # Determine new tile colors
  tile_table[, 'color'] <- new_colors          # Set new tile colors
  setTxtProgressBar(pb, i)
}
close(pb)

answer2 <- sum(tile_table[,'color'] == 'black')  # Count the black tiles

# Answer: 3706
# Run Time:
#    user  system elapsed 
# 817.908   0.251 816.945 