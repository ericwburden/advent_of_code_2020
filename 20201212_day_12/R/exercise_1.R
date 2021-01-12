#' **--- Day 12: Rain Risk ---**
#'   
#' Your ferry made decent progress toward the island, but the storm came in 
#' faster than anyone expected. The ferry needs to take evasive actions!
#'   
#' Unfortunately, the ship's navigation computer seems to be malfunctioning; 
#' rather than giving a route directly to safety, it produced extremely 
#' circuitous instructions. When the captain uses the PA system to ask if 
#' anyone can help, you quickly volunteer.
#' 
#' The navigation instructions (your puzzle input) consists of a sequence of 
#' single-character actions paired with integer input values. After staring at 
#' them for a few minutes, you work out what they probably mean:
#' 
#' - Action N means to move north by the given value.
#' - Action S means to move south by the given value.
#' - Action E means to move east by the given value.
#' - Action W means to move west by the given value.
#' - Action L means to turn left the given number of degrees.
#' - Action R means to turn right the given number of degrees.
#' - Action F means to move forward by the given value in the direction the 
#' ship is currently facing.
#' 
#' The ship starts by facing east. Only the L and R actions change the 
#' direction the ship is facing. (That is, if the ship is facing east and the 
#' next instruction is N10, the ship would move north 10 units, but would still 
#' move east if the following action were F.)
#' 
#' For example:
#' 
#' ```
#' F10
#' N3
#' F7
#' R90
#' F11
#' ```
#' 
#' These instructions would be handled as follows:
#' 
#' - F10 would move the ship 10 units east (because the ship starts by facing 
#' east) to east 10, north 0.
#' - N3 would move the ship 3 units north to east 10, north 3.
#' - F7 would move the ship another 7 units east (because the ship is still 
#' facing east) to east 17, north 3.
#' - R90 would cause the ship to turn right by 90 degrees and face south; it 
#' remains at east 17, north 3.
#' - F11 would move the ship 11 units south to east 17, south 8.
#' 
#' At the end of these instructions, the ship's Manhattan distance (sum of the 
#' absolute values of its east/west position and its north/south position) from 
#' its starting position is 17 + 8 = 25.
#' 
#' Figure out where the navigation instructions lead. What is the Manhattan 
#' distance between that location and the ship's starting position?

test_input <- c("F10", "N3", "F7", "R90", "F11")
real_input <- readLines('../input.txt')

# Helper function, given a list of strings in the format 'CN' where 'C' is an
# uppercase character (one of 'N', 'S', 'E', 'W', 'L', 'R', 'F') and 'N' is 
# a numeric character or characters. Returns a list where each element is a
# named list of the format list(list(dir = 'C', mag = 'N'), ...)
parse_input <- function(input) {
  navs <- strsplit(input, '(?<=[A-Z])(?=\\d)', perl = T)
  lapply(navs, function(x) { list(dir = x[1], mag = as.numeric(x[2])) })
}

# Helper function, given a `dir` of 'L' or 'R', a magnitude `mag`, and the
# ship's current position in the structure we have defined. Returns the 
# ship's new heading as 'N', 'E', 'S', or 'W' based on the indicated
# rotation of the ship
new_heading <- function(dir, mag, ship_pos) {
  dirs <- c('N', 'E', 'S', 'W')
  rotation <- if (dir == 'L') { -1 } else { 1 }  # Direction of rotation
  di <- rotation * ((mag/90) %% 4)               # Times to move 90 degrees
  
  # Changes the heading, wrapping around the ends of the `dirs` vector as needed
  heading <- which(dirs == ship_pos[['H']]) + di
  if (heading < 1) { heading <- heading + 4 }
  if (heading > 4) { heading <- heading - 4 }
  dirs[[heading]]
}

# Main function, moves the ship. Given a `dir` and `mag` from a navigation 
# instruction and the ship's current position as `ship_pos`, returns the ship's
# new position after applying the instruction
move_ship <- function(dir, mag, ship_pos) {
  # If `dir` is one of 'N', 'S', 'E', or 'W', change the ship's position that
  # direction
  if (dir == 'N') { ship_pos$Y <- ship_pos$Y + mag}
  if (dir == 'S') { ship_pos$Y <- ship_pos$Y - mag}
  if (dir == 'E') { ship_pos$X <- ship_pos$X + mag}
  if (dir == 'W') { ship_pos$X <- ship_pos$X - mag}
  
  # If the `dir` is 'L' or 'R', rotate the ship
  if (dir %in% c('L', 'R')) { ship_pos[['H']] <- new_heading(dir, mag, ship_pos) }
  
  # Move the ship 'forward' in it's current direction
  if (dir == 'F') { ship_pos <- move_ship(ship_pos$H, mag, ship_pos) }
  
  ship_pos
}

# A handy structure to store the ship's position
ship_pos <- list(X = 0, Y = 0, H = 'E')  
navigation <- parse_input(real_input)  # Parse input
for (nav in navigation) { ship_pos <- move_ship(nav$dir, nav$mag, ship_pos) }
answer1 <- abs(ship_pos$X) + abs(ship_pos$Y)



