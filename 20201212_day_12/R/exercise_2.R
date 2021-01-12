#' **--- Part Two ---**
#'   
#' Before you can give the destination to the captain, you realize that the 
#' actual action meanings were printed on the back of the instructions the 
#' whole time.
#' 
#' Almost all of the actions indicate how to move a waypoint which is relative 
#' to the ship's position:
#' 
#' - Action N means to move the waypoint north by the given value.
#' - Action S means to move the waypoint south by the given value.
#' - Action E means to move the waypoint east by the given value.
#' - Action W means to move the waypoint west by the given value.
#' - Action L means to rotate the waypoint around the ship left 
#' (counter-clockwise) the given number of degrees.
#' - Action R means to rotate the waypoint around the ship right (clockwise) 
#' the given number of degrees.
#' - Action F means to move forward to the waypoint a number of times equal to the given value.
#' 
#' The waypoint starts 10 units east and 1 unit north relative to the ship. The 
#' waypoint is relative to the ship; that is, if the ship moves, the waypoint 
#' moves with it.
#' 
#' For example, using the same instructions as above:
#' 
#' - F10 moves the ship to the waypoint 10 times (a total of 100 units east and 
#' 10 units north), leaving the ship at east 100, north 10. The waypoint stays 
#' 10 units east and 1 unit north of the ship.
#' - N3 moves the waypoint 3 units north to 10 units east and 4 units north of 
#' the ship. The ship remains at east 100, north 10.
#' - F7 moves the ship to the waypoint 7 times (a total of 70 units east and 
#' 28 units north), leaving the ship at east 170, north 38. The waypoint stays 
#' 10 units east and 4 units north of the ship.
#' - R90 rotates the waypoint around the ship clockwise 90 degrees, moving it 
#' to 4 units east and 10 units south of the ship. The ship remains at east 
#' 170, north 38.
#' - F11 moves the ship to the waypoint 11 times (a total of 44 units east and 
#' 110 units south), leaving the ship at east 214, south 72. The waypoint stays 
#' 4 units east and 10 units south of the ship.
#' 
#' After these operations, the ship's Manhattan distance from its starting 
#' position is 214 + 72 = 286.
#' 
#' Figure out where the navigation instructions actually lead. What is the 
#' Manhattan distance between that location and the ship's starting position?

source('exercise_1.R')

# Helper function, given a number of times to move the ship `n`, the ship's
# position `ship`, and a waypoint's position `waypoint`, 'move' the ship to 
# the waypoint `n` times.
ship_to_waypoint <- function(n, ship, waypoint) {
  for (i in seq(n)) {
    ship$X <- ship$X + waypoint$X
    ship$Y <- ship$Y + waypoint$Y
  }
  ship
}

# Helper function, given a direction to rotate `dir`, an amount to rotate `mag`
rotate <- function(dir, mag, waypoint) {
  rotation_dir <- if (dir == 'L') { -1 } else { 1 }
  rotation_mag <- mag %% 360
  
  if (rotation_mag == 0) { 
    new_X <- waypoint$X
    new_Y <- waypoint$Y
  }
  if (rotation_mag == 90) { 
    new_X <- waypoint$Y * rotation_dir
    new_Y <- waypoint$X * -rotation_dir
  }
  if (rotation_mag == 180) { 
    new_X <- -waypoint$X
    new_Y <- -waypoint$Y
  }
  if (rotation_mag == 270) { 
    new_X <- waypoint$Y * -rotation_dir
    new_Y <- waypoint$X * rotation_dir
  }
  
  waypoint$X <- new_X
  waypoint$Y <- new_Y
  waypoint
}

move <- function(dir, mag, system) {
  within(system, {
    if (dir == 'N') { waypoint$Y <- waypoint$Y + mag}
    if (dir == 'S') { waypoint$Y <- waypoint$Y - mag}
    if (dir == 'E') { waypoint$X <- waypoint$X + mag}
    if (dir == 'W') { waypoint$X <- waypoint$X - mag}
    if (dir == 'F') { ship <- ship_to_waypoint(mag, ship, waypoint)}
    if (dir %in% c('L', 'R')) { waypoint <- rotate(dir, mag, waypoint)}
  })
}

system <- list(waypoint = list(X = 10, Y = 1), ship = list(X = 0, Y = 0))
navigation <- parse_input(real_input)
for (nav in navigation) { system <- move(nav$dir, nav$mag, system) }
answer <- abs(system$ship$X) + abs(system$ship$Y)

