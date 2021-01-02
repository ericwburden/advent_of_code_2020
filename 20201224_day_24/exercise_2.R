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

source('exercise_1.R')


# Function ---------------------------------------------------------------------

# Given a index to a three-dimensional array `i` and a three-dimensional array
# `tile_map`, returns the value at that index of the array. Provides safety 
# against referencing indices that aren't actually present in the array.
get_tile_value <- function(i, tile_map) {
  # If the index is not in the array, `val` is NA
  val <- tryCatch(
    val <- tile_map[i[1], i[2], i[3]],
    error = function(e) { NA_real_ }
  )
  
  # Oddly, if any of the elements of `i` is `0`, the index operator doesn't
  # throw an error but returns numeric(0), so we need to test for that.
  if (length(val) > 0) { val } else { NA_real_ }
}


# Given an index to a three-dimensional array `tile_index` and a 
# three-dimensional array `tile_map`, returns the number of black tiles 
# neighboring the element at index `tile_index`.
get_neighbors <- function(tile_index, tile_map) {
  arr_index <- arrayInd(tile_index, dim(tile_map))

  neighbor_offsets <- list(
    c(0,  1, -1), c( 1, 0, -1), c( 1, -1, 0),
    c(0, -1,  1), c(-1, 0,  1), c(-1,  1, 0)
  )
  neighbor_indices <- lapply(neighbor_offsets, `+`, arr_index)
  neighbor_values <- vapply(neighbor_indices, get_tile_value, numeric(1), tile_map)
  sum(neighbor_values, na.rm = T)
}


# Given a 3D array `tile_map`, returns the elements (in a 1D vector) on the
# outer edges of the array.
get_shell <- function(tile_map) {
  d <- dim(tile_map)
  d1_edge_cells <- tile_map[c(1, d[1]), ,  ]
  d2_edge_cells <- tile_map[ , c(1, d[2]), ]
  d3_edge_cells <- tile_map[ , , c(1, d[3])]
  c(d1_edge_cells, d2_edge_cells, d3_edge_cells)
}


# Given an index to a 3D array `tile_index` and a 3D array `tile_map`, return
# the state of the element at index `tile_index` after applying the rules
# for changing element state in the puzzle description.
next_tile_state <- function(tile_index, tile_map) {
  tile_value <- tile_map[tile_index]
  if (is.na(tile_value)) { return(NA_real_) }
  
  neighbors_value <- get_neighbors(tile_index, tile_map)
  if (tile_value == 1 && (neighbors_value == 0 | neighbors_value > 2)) {
    0
  } else if (tile_value == 0 && neighbors_value == 2) {
    1
  } else {
    tile_value
  }
}


# Given a 3D array `tile_map` and the number of 'layers' to expand the array by
# `expand_by`, add `expand_by` additional layers to the outside of the array
# and return it.
expand_tile_map <- function(tile_map, expand_by = 1) {
  old_dims <- dim(tile_map)
  new_dims <- old_dims + (2 * expand_by)
  new_center <- ceiling(new_dims / 2)
  new_map <- array(dim = new_dims)
  
  all_coords <- arrayInd(1:prod(new_dims), new_dims)
  tile_coords <- all_coords[rowSums(all_coords) == sum(new_center),]
  new_map[tile_coords] <- 0
  
  r1 <- new_center - floor(old_dims / 2)
  r2 <- new_center + floor(old_dims / 2)
  new_map[r1[1]:r2[1], r1[2]:r2[2], r1[3]:r2[3]] <- tile_map
  
  new_map
}

# Processing -------------------------------------------------------------------

# Advance the floor state 100 times, starting with the floor state at the end
# of part one.
rounds <- 100
pb <- txtProgressBar(max = rounds, style = 3)
for (i in 1:rounds) {
  
  # If there are any black tiles on the outer edge of the `tile_map`, then we 
  # 'may' need to flip tiles that don't exist yet, so we go ahead and add an
  # extra layer of white tiles to the outside.
  if (any(get_shell(tile_map) == 1, na.rm = T)) { 
    tile_map <- expand_tile_map(tile_map) 
  }
  
  # Advance the floor state by iterating over the `tile_map` and calculating 
  # the next state for each element
  tile_map <- apply(
    slice.index(tile_map, c(1, 2, 3)), 
    c(1, 2, 3), 
    next_tile_state, 
    tile_map
  )
  
  setTxtProgressBar(pb, i)
}
close(pb)

answer2 <- sum(tile_map, na.rm = T)  # Sum the number of black tiles

# Answer: 3706
# Run Time:
#    user  system elapsed 
# 330.447   0.378 331.982 

