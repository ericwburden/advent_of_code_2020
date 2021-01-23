# Setup ------------------------------------------------------------------------

test_input <- c(
  "sesenwnenenewseeswwswswwnenewsewsw",
  "neeenesenwnwwswnenewnwwsewnenwseswesw",
  "seswneswswsenwwnwse",
  "nwnwneseeswswnenewneswwnewseswneseene",
  "swweswneswnenwsewnwneneseenw",
  "eesenwseswswnenwswnwnwsewwnwsene",
  "sewnenenenesenwsewnenwwwse",
  "wenwwweseeeweswwwnwwe",
  "wsweesenenewnwwnwsenewsenwwsesesenwne",
  "neeswseenwwswnwswswnw",
  "nenwswwsewswnenenewsenwsenwnesesenew",
  "enewnwewneswsewnwswenweswnenwsenwsw",
  "sweneswneswneneenwnewenewwneswswnese",
  "swwesenesewenwneswnwwneseswwne",
  "enesenwswwswneneswsenwnewswseenwsese",
  "wnwnesenesenenwwnenwsewesewsesesew",
  "nenewswnwewswnenesenwnesewesw",
  "eneswnwswnwsenenwnwnwwseeswneewsenese",
  "neswnwewnwnwseenwseesewsenwsweewe",
  "wseweeenwnesenwwwswnew"
)
real_input <- readLines('input.txt')


# Mapping of compass directions to offsets in three-dimensional space
dir_map <- list(
  nw = c( 0,  1, -1),
  ne = c( 1,  0, -1),
  e =  c( 1, -1,  0),
  se = c( 0, -1,  1),
  sw = c(-1,  0,  1),
  w  = c(-1,  1,  0)
)


# Functions --------------------------------------------------------------------

# Given a vector of strings where each string represents a direction to move
# from the center `dirs` and a mapping of individual direction strings to 
# three-dimensional coordinate offsets `dir_map`, return the final offset
# in three-dimensional coordinates indicated by the directions.
parse_directions <- function(dirs, dir_map) {
  final_location <- c(0, 0, 0)
  for (dir in dirs) { final_location <- final_location + dir_map[[dir]] }
  final_location
}


# Given a vector of strings from the puzzle input `input` and a mapping of
# individual compass directions to three-dimensional coordinate offsets 
# `dir_map`, return a list of three-dimensional offsets resulting from following
# the set of directions in each element of `input`
parse_input <- function(input, dir_map) {
  tokens <- regmatches(input, gregexpr('(e|w|[ns][ew])', input))
  lapply(tokens, parse_directions, dir_map)
}


# Given a the maximum distance from a central point of any individual tile 
# offset `max_offset`, returns a data frame containing columns for `x`, `y`, 
# `z`, and `color`, where each row in the data frame represents an individual
# tile with coordinates.
build_tile_table <- function(max_offset) {
  offset_range <- c(-(max_offset):(max_offset))   # The maximum range of offsets
  
  # Create a data frame containing all combinations of the values in the
  # `offset_range`, then filter out any rows where the coordinates do not
  # sum to zero
  all_coords <- expand.grid(x = offset_range, y = offset_range, z = offset_range)
  tile_coords <- all_coords[rowSums(all_coords) == 0,]
  
  # Return a data frame containing all the remaining coordinates and 'white'
  # for the color
  data.frame(
    x = tile_coords$x, y = tile_coords$y, z = tile_coords$z, 
    color = 'white', stringsAsFactors = FALSE
  )
}


# Given an index relative to the central tile `relative_tile_loc` and a data
# frame of tile locations, 'flip' the color of the tile on the row indicated
# by `relative_tile_loc`
flip_tile <- function(relative_tile_loc, tile_table) {
  selector <- (
    tile_table$x == relative_tile_loc[1] &
    tile_table$y == relative_tile_loc[2] &
    tile_table$z == relative_tile_loc[3]
  )
  current_color <- tile_table[selector, 'color']
  tile_table[selector, 'color'] <- ifelse(current_color == 'white', 'black', 'white')
  tile_table
}


# Processing -------------------------------------------------------------------

relative_tile_locs <- parse_input(real_input, dir_map)  # Parse the input directions
max_offset <- max(abs(unlist(relative_tile_locs)))      # Max tile offset in any direction
tile_table <- build_tile_table(max_offset)              # Create a data frame of tiles

# For each set of directions, flip the indicated tile
for (loc in relative_tile_locs) { tile_table <- flip_tile(loc, tile_table) }
answer1 <- sum(tile_table$color == 'black')  # Count the black tiles


# Answer: 269

