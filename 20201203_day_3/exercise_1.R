#'**--- Day 3: Toboggan Trajectory ---**
#'
#'  With the toboggan login problems resolved, you set off toward the airport.
#'  While travel by toboggan might be easy, it's certainly not safe: there's
#'  very minimal steering and the area is covered in trees. You'll need to see
#'  which angles will take you near the fewest trees.
#'
#'  Due to the local geology, trees in this area only grow on exact integer
#'  coordinates in a grid. You make a map (your puzzle input) of the open
#'  squares (.) and trees (#) you can see. For example:
#'
#' ```
#' ..##.......
#' #...#...#..
#' .#....#..#.
#' ..#.#...#.#
#' .#...##..#.
#' ..#.##.....
#' .#.#.#....#
#' .#........#
#' #.##...#...
#' #...##....#
#' .#..#...#.#
#' ```
#'
#' These aren't the only trees, though; due to something you read about once
#' involving arboreal genetics and biome stability, the same pattern repeats
#' to the right many times:
#'
#' ```
#' ..##.........##.........##.........##.........##.........##.......  --->
#' #...#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
#' .#....#..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
#' ..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
#' .#...##..#..#...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
#' ..#.##.......#.##.......#.##.......#.##.......#.##.......#.##.....  --->
#' .#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
#' .#........#.#........#.#........#.#........#.#........#.#........#
#' #.##...#...#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...
#' #...##....##...##....##...##....##...##....##...##....##...##....#
#' .#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#  --->
#' ```
#'
#' You start on the open square (.) in the top-left corner and need to reach
#' the bottom (below the bottom-most row on your map).
#'
#' The toboggan can only follow a few specific slopes (you opted for a cheaper
#' model that prefers rational numbers); start by counting all the trees you
#' would encounter for the slope right 3, down 1:
#'
#' From your starting position at the top-left, check the position that is
#' right 3 and down 1. Then, check the position that is right 3 and down 1
#' from there, and so on until you go past the bottom of the map.
#'
#' The locations you'd check in the above example are marked here with O where
#' there was an open square and X where there was a tree:
#'
#' ```
#' ..##.........##.........##.........##.........##.........##.......  --->
#' #..O#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
#' .#....X..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
#' ..#.#...#O#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
#' .#...##..#..X...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
#' ..#.##.......#.X#.......#.##.......#.##.......#.##.......#.##.....  --->
#' .#.#.#....#.#.#.#.O..#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
#' .#........#.#........X.#........#.#........#.#........#.#........#
#' #.##...#...#.##...#...#.X#...#...#.##...#...#.##...#...#.##...#...
#' #...##....##...##....##...#X....##...##....##...##....##...##....#
#' .#..#...#.#.#..#...#.#.#..#...X.#.#..#...#.#.#..#...#.#.#..#...#.#  --->
#' ```
#'
#' In this example, traversing the map using this slope would cause you to
#' encounter 7 trees.
#'
#' Starting at the top-left corner of your map and following a slope of right
#' 3 and down 1, how many trees would you encounter?

library(stringr)
library(purrr)

test_pattern <- "..##.......
                 #...#...#..
                 .#....#..#.
                 ..#.#...#.#
                 .#...##..#.
                 ..#.##.....
                 .#.#.#....#
                 .#........#
                 #.##...#...
                 #...##....#
                 .#..#...#.#"

input <- paste(readLines('input.txt'), collapse = '\n')

#' Helper function, converts a character map to a matrix
trees_map <- function(pattern) {
  pattern_no_whitespace <- str_remove_all(pattern, '[ \\t]')
  lines <- str_split(pattern_no_whitespace, '\n', simplify = T)
  line_vecs <- str_split(lines, '')
  mmap <- reduce(line_vecs, rbind)
  row.names(mmap) <- seq(nrow(mmap))

  mmap
}

#' Helper function to pretty print a map with trees and the cursor marked
pprint <- function(tmap, trees, cursor) {
  tmap[tmap == '#'] <- crayon::green('#')

  tmap[cursor['row'], cursor['col']] <- crayon::blue('O')

  for (tree in trees) {
    tmap[tree['row'], tree['col']] <- crayon::red('X')
  }

  cat_rows <- apply(tmap, 1, paste, collapse = '')
  cat('\014', '\n\n')
  cat(cat_rows, sep = '\n')
  cat('\n\n')
}

#' Traverse the map and count the number of trees encountered
trees_encountered <- function(tmap, slope, animate = F) {
  cursor <- c(row = 1, col = 1)
  trees <- list()
  map_h <- nrow(tmap)
  map_w <- ncol(tmap)

  while(cursor['row'] <= nrow(tmap)) {
    # If the cursor is on the right edge of the map, extend it
    if (cursor['col'] > ncol(tmap)) {
      tmap <- cbind(tmap, tmap[1:map_h, 1:map_w])
    }

    # If the cursor is on a tree, add the tree to the list
    if (tmap[cursor['row'], cursor['col']] == '#') {
      trees[[length(trees) + 1]] <- cursor
    }

    # If we're animating, print to console
    if (animate) {
      pprint(tmap, trees, cursor)
      Sys.sleep(.75)
    }

    # Move the cursor according to the current slop
    cursor <- cursor + slope
  }

  trees
}

tmap <- trees_map(test_pattern)
found_trees <- trees_encountered(tmap, c(1, 3), T)
length(found_trees)
