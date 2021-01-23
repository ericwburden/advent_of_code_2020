# --- Day 24: Lobby Layout ---
#   
# Your raft makes it to the tropical island; it turns out that the small crab 
# was an excellent navigator. You make your way to the resort.
# 
# As you enter the lobby, you discover a small problem: the floor is being 
# renovated. You can't even reach the check-in desk until they've finished 
# installing the new tile floor.
# 
# The tiles are all hexagonal; they need to be arranged in a hex grid with a 
# very specific color pattern. Not in the mood to wait, you offer to help 
# figure out the pattern.
# 
# The tiles are all white on one side and black on the other. They start with 
# the white side facing up. The lobby is large enough to fit whatever pattern 
# might need to appear there.
# 
# A member of the renovation crew gives you a list of the tiles that need to 
# be flipped over (your puzzle input). Each line in the list identifies a 
# single tile that needs to be flipped by giving a series of steps starting 
# from a reference tile in the very center of the room. (Every line starts 
# from the same reference tile.)
# 
# Because the tiles are hexagonal, every tile has six neighbors: east, 
# southeast, southwest, west, northwest, and northeast. These directions are 
# given in your list, respectively, as e, se, sw, w, nw, and ne. A tile is 
# identified by a series of these directions with no delimiters; for example, 
# esenee identifies the tile you land on if you start at the reference tile and 
# then move one tile east, one tile southeast, one tile northeast, and one tile 
# east.
# 
# Each time a tile is identified, it flips from white to black or from black to 
# white. Tiles might be flipped more than once. For example, a line like esew 
# flips a tile immediately adjacent to the reference tile, and a line like 
# nwwswee flips the reference tile itself.
# 
# Here is a larger example:
#   
# sesenwnenenewseeswwswswwnenewsewsw
# neeenesenwnwwswnenewnwwsewnenwseswesw
# seswneswswsenwwnwse
# nwnwneseeswswnenewneswwnewseswneseene
# swweswneswnenwsewnwneneseenw
# eesenwseswswnenwswnwnwsewwnwsene
# sewnenenenesenwsewnenwwwse
# wenwwweseeeweswwwnwwe
# wsweesenenewnwwnwsenewsenwwsesesenwne
# neeswseenwwswnwswswnw
# nenwswwsewswnenenewsenwsenwnesesenew
# enewnwewneswsewnwswenweswnenwsenwsw
# sweneswneswneneenwnewenewwneswswnese
# swwesenesewenwneswnwwneseswwne
# enesenwswwswneneswsenwnewswseenwsese
# wnwnesenesenenwwnenwsewesewsesesew
# nenewswnwewswnenesenwnesewesw
# eneswnwswnwsenenwnwnwwseeswneewsenese
# neswnwewnwnwseenwseesewsenwsweewe
# wseweeenwnesenwwwswnew
# 
# In the above example, 10 tiles are flipped once (to black), and 5 more are 
# flipped twice (to black, then back to white). After all of these instructions 
# have been followed, a total of 10 tiles are black.
# 
# Go through the renovation crew's list and determine which tiles they need to 
# flip. After all of the instructions have been followed, how many tiles are 
# left with the black side up?

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
# offset `max_offset`, return a three-dimensional array large enough to 
# encompass the entire 'floor', where each array element is either `NA` or `0`. 
# A `0` represents the location of a white tile in the floor, an `NA` represents 
# a space in the matrix that is not a part of the floor. These `NA`'s are 
# essentially ignored.
init_tile_map <- function(max_offset) {
  offset_range <- c(-max_offset:max_offset)     # The maximum range of offsets
  map_dim <- (max_offset * 2) + 1               # The dimensions of the array
  tile_map <- array(NA, dim = rep(map_dim, 3))  # Empty array of sufficient size
  center <- rep(ceiling(map_dim / 2), 3)        # The center point of the array
  
  # Only the array indices that sum to the same value as the central index 
  # would be included in the diagonal slice of the array representing the
  # floor. Those tiles start off as white (`0`)
  all_coords <- arrayInd(1:map_dim^3, rep(map_dim, 3))
  tile_coords <- all_coords[rowSums(all_coords) == sum(center),]
  tile_map[tile_coords] <- 0
  
  tile_map  # Return the tile_map
}


# Given an offset from the `tile_map`'s central point `relative_tile_loc` and 
# a three-dimensional array containing the locations of tiles in the floor 
# `tile_map`, 'flips' the tile indicated by `relative_tile_loc`, i.e. toggles
# the array index value between `1` and `0`
flip_tile <- function(relative_tile_loc, tile_map) {
  center <- ceiling(dim(tile_map) / 2)  # Array central point
  ti <- center + relative_tile_loc      # Absolute array index of the tile
  
  # 'Flip' the tile (toggle the value)
  tile_map[ti[1], ti[2], ti[3]] <- abs(1 - tile_map[ti[1], ti[2], ti[3]])

  tile_map  # Return the modified matrix
}


# Processing -------------------------------------------------------------------

relative_tile_locs <- parse_input(real_input, dir_map)  # Parse the input directions
max_offset <- max(abs(unlist(relative_tile_locs)))      # Max tile offset in any direction
tile_map <- init_tile_map(max_offset)                   # Initialize the tile map array

# For each tile that needs to be flipped, flip it!
for (loc in relative_tile_locs) { tile_map <- flip_tile(loc, tile_map) }

answer1 <- sum(tile_map, na.rm = T)  # Sum of all tile values, black tiles = 1

# Answer: 269

