# --- Part Two ---
#   
# Now, you're ready to check the image for sea monsters.
# 
# The borders of each tile are not part of the actual image; start by removing 
# them.
# 
# In the example above, the tiles become:
# 
# .#.#..#. ##...#.# #..#####
# ###....# .#....#. .#......
# ##.##.## #.#.#..# #####...
# ###.#### #...#.## ###.#..#
# ##.#.... #.##.### #...#.##
# ...##### ###.#... .#####.#
# ....#..# ...##..# .#.###..
# .####... #..#.... .#......
# 
# #..#.##. .#..###. #.##....
# #.####.. #.####.# .#.###..
# ###.#.#. ..#.#### ##.#..##
# #.####.. ..##..## ######.#
# ##..##.# ...#...# .#.#.#..
# ...#..#. .#.#.##. .###.###
# .#.#.... #.##.#.. .###.##.
# ###.#... #..#.##. ######..
# 
# .#.#.### .##.##.# ..#.##..
# .####.## #.#...## #.#..#.#
# ..#.#..# ..#.#.#. ####.###
# #..####. ..#.#.#. ###.###.
# #####..# ####...# ##....##
# #.##..#. .#...#.. ####...#
# .#.###.. ##..##.. ####.##.
# ...###.. .##...#. ..#..###
# 
# Remove the gaps to form the actual image:
# 
# .#.#..#.##...#.##..#####
# ###....#.#....#..#......
# ##.##.###.#.#..######...
# ###.#####...#.#####.#..#
# ##.#....#.##.####...#.##
# ...########.#....#####.#
# ....#..#...##..#.#.###..
# .####...#..#.....#......
# #..#.##..#..###.#.##....
# #.####..#.####.#.#.###..
# ###.#.#...#.######.#..##
# #.####....##..########.#
# ##..##.#...#...#.#.#.#..
# ...#..#..#.#.##..###.###
# .#.#....#.##.#...###.##.
# ###.#...#..#.##.######..
# .#.#.###.##.##.#..#.##..
# .####.###.#...###.#..#.#
# ..#.#..#..#.#.#.####.###
# #..####...#.#.#.###.###.
# #####..#####...###....##
# #.##..#..#...#..####...#
# .#.###..##..##..####.##.
# ...###...##...#...#..###
# 
# Now, you're ready to search for sea monsters! Because your image is 
# monochrome, a sea monster will look like this:
#   
#                     # 
#   #    ##    ##    ###
#    #  #  #  #  #  #   
#   
# When looking for this pattern in the image, the spaces can be anything; only 
# the # need to match. Also, you might need to rotate or flip your image before 
# it's oriented correctly to find sea monsters. In the above image, after 
# flipping and rotating it to the appropriate orientation, there are two sea 
# monsters (marked with O):
# 
# .####...#####..#...###..
# #####..#..#.#.####..#.#.
# .#.#...#.###...#.##.O#..
# #.O.##.OO#.#.OO.##.OOO##
# ..#O.#O#.O##O..O.#O##.##
# ...#.#..##.##...#..#..##
# #.##.#..#.#..#..##.#.#..
# .###.##.....#...###.#...
# #.####.#.#....##.#..#.#.
# ##...#..#....#..#...####
# ..#.##...###..#.#####..#
# ....#.##.#.#####....#...
# ..##.##.###.....#.##..#.
# #...#...###..####....##.
# .#.##...#.##.#.#.###...#
# #.###.#..####...##..#...
# #.###...#.##...#.##O###.
# .O##.#OO.###OO##..OOO##.
# ..O#.O..O..O.#O##O##.###
# #.#..##.########..#..##.
# #.#####..#.#...##..#....
# #....##..#.#########..##
# #...#.....#..##...###.##
# #..###....##.#...##.##.#
# 
# Determine how rough the waters are in the sea monsters' habitat by counting 
# the number of # that are not part of a sea monster. In the above example, the 
# habitat's water roughness is 273.
# 
# How many # are not part of a sea monster?

# Setup ------------------------------------------------------------------------

source('exercise_1.R')


# Functions --------------------------------------------------------------------

# Helper function, given a single number index to a matrix `i` and the 
# matrix `full_image`, checks that index to determine if it is attached
# to a sea monster, returns TRUE if so
is_sea_monster <- function(i, full_image) {
  
  # Convert single numeric index ('1') to array index ([1, 1])
  arr_ind <- which(slice.index(full_image, c(1, 2)) == i, arr.ind = T)
  mr <- arr_ind[1]
  mc <- arr_ind[2]
  
  # Starting with the tip of the sea monster's tail [mr, mc], a mapping
  # of the indices that need to contain a '#' in order to signify a
  # sea monster
  monster_indices <- list(
    c(mr, mc),     c(mr+1, mc+1),  c(mr+1, mc+4),  c(mr, mc+5),
    c(mr, mc+6),   c(mr+1, mc+7),  c(mr+1, mc+10), c(mr, mc+11),
    c(mr, mc+12),  c(mr+1, mc+13), c(mr+1, mc+16), c(mr, mc+17),
    c(mr-1, mc+18), c(mr, mc+18),  c(mr, mc+19)
  )
  
  # Do all the `monster_indices` contain a '#'?
  all(sapply(monster_indices, function(x) full_image[x[1], x[2]] == '#'))
}

# Processing -------------------------------------------------------------------


# The full image size will be the length/width of the `tile_arrangement` times
# 8, since each image square tile is an 8x8 matrix once the outer layer is 
# removed
img_dim <- sqrt(length(matched_tiles)) * 8
full_image <- matrix(NA_character_, nrow = img_dim, ncol = img_dim)

# `spacing` provides a list to pull the top left indices of each image tile
# in the full image. The first tile will have a top left corner at [1, 1]. 
# Moving across it's [1, 9], [1, 17], etc.
spacing <- seq(1, img_dim, 8)

# Fill in the empty `full_image` matrix with the characters from each tile. Use
# the `tile_arrangement` matrix to identify where in the `full_image` to place
# each tile's characters
for (i in slice.index(cropped_arrangement, c(1, 2))) {
  
  # Convert single numeric index ('1') to array index ([1, 1])
  arr_ind <- which(cropped_arrangement == cropped_arrangement[i], arr.ind = T)
  mr <- arr_ind[1]
  mc <- arr_ind[2]
  
  # Get the tile contents to add to the `full_image`, minus the outer layer
  tile_name <- cropped_arrangement[i]
  tile <- matched_tiles[[tile_name]]
  tile_contents <- tile$tile[2:9,2:9]
  
  # Add tile contents to the appropriate section of `full_image`
  img_row_range <- spacing[mr]:(spacing[mr]+7)
  img_col_range <- spacing[mc]:(spacing[mc]+7)
  full_image[(img_row_range),(img_col_range)] <- tile_contents
}

# Flip and rotate the image until a sea monster appears. The 
# `monster_check_range` is a subset of the `full_image`, accounting for the
# valid spaces where the tip of a sea monster's tail could be and preventing
# 'index out of bounds' errors.
monster_check_range <- slice.index(full_image, c(1, 2))[2:(img_dim-1), 1:(img_dim-19)]

# For each permutation of `full_image`...
for (t in 1:8) {
  found_it <- FALSE
  
  # Check each index in `monster_check_range` for a sea monster. If found,
  # break out of both 'for' loops, leaving the `full_image` in the state where
  # a sea monster was found.
  for (i in monster_check_range) {
    if (is_sea_monster(i, full_image)) { found_it <- TRUE; break }
  }
  if (found_it) { break }
  full_image <- if (t == 5) { flip(full_image) } else { rotate(full_image) }
}

# Now that we know `full_image` is in the proper orientation, count the sea
# monsters
sea_monsters <- 0
for (i in monster_check_range) {
  if (is_sea_monster(i, full_image)) { sea_monsters <- sea_monsters + 1 }
}

# Each sea monster contains 15 hashes, so the number of non-sea-monster hashes
# must be the total number of hashes minus the number of hashes in sea monsters
hash_count <- sum(full_image == '#')
answer2 <- hash_count - (sea_monsters * 15)

# Answer: 2323