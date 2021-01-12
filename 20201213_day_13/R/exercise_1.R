#' **--- Day 13: Shuttle Search ---**
#'   
#' Your ferry can make it safely to a nearby port, but it won't get much 
#' further. When you call to book another ship, you discover that no ships 
#' embark from that port to your vacation island. You'll need to get from the 
#' port to the nearest airport.
#' 
#' Fortunately, a shuttle bus service is available to bring you from the sea 
#' port to the airport! Each bus has an ID number that also indicates how often 
#' the bus leaves for the airport.
#' 
#' Bus schedules are defined based on a timestamp that measures the number of 
#' minutes since some fixed reference point in the past. At timestamp 0, every 
#' bus simultaneously departed from the sea port. After that, each bus travels 
#' to the airport, then various other locations, and finally returns to the sea 
#' port to repeat its journey forever.
#' 
#' The time this loop takes a particular bus is also its ID number: the bus 
#' with ID 5 departs from the sea port at timestamps 0, 5, 10, 15, and so on. 
#' The bus with ID 11 departs at 0, 11, 22, 33, and so on. If you are there 
#' when the bus departs, you can ride that bus to the airport!
#'   
#' Your notes (your puzzle input) consist of two lines. The first line is your 
#' estimate of the earliest timestamp you could depart on a bus. The second 
#' line lists the bus IDs that are in service according to the shuttle company; 
#' entries that show x must be out of service, so you decide to ignore them.
#' 
#' To save time once you arrive, your goal is to figure out the earliest bus 
#' you can take to the airport. (There will be exactly one such bus.)
#' 
#' For example, suppose you have the following notes:
#'   
#' 939
#' 7,13,x,x,59,x,31,19
#' 
#' Here, the earliest timestamp you could depart is 939, and the bus IDs in 
#' service are 7, 13, 59, 31, and 19. Near timestamp 939, these bus IDs depart 
#' at the times marked D:
#'   
#' time   bus 7   bus 13  bus 59  bus 31  bus 19
#' 929      .       .       .       .       .
#' 930      .       .       .       D       .
#' 931      D       .       .       .       D
#' 932      .       .       .       .       .
#' 933      .       .       .       .       .
#' 934      .       .       .       .       .
#' 935      .       .       .       .       .
#' 936      .       D       .       .       .
#' 937      .       .       .       .       .
#' 938      D       .       .       .       .
#' 939      .       .       .       .       .
#' 940      .       .       .       .       .
#' 941      .       .       .       .       .
#' 942      .       .       .       .       .
#' 943      .       .       .       .       .
#' 944      .       .       D       .       .
#' 945      D       .       .       .       .
#' 946      .       .       .       .       .
#' 947      .       .       .       .       .
#' 948      .       .       .       .       .
#' 949      .       D       .       .       .
#' 
#' The earliest bus you could take is bus ID 59. It doesn't depart until 
#' timestamp 944, so you would need to wait 944 - 939 = 5 minutes before it 
#' departs. Multiplying the bus ID by the number of minutes you'd need to wait 
#' gives 295.
#' 
#' What is the ID of the earliest bus you can take to the airport multiplied 
#' by the number of minutes you'll need to wait for that bus?

test_input <- c(
  "939",
  "7,13,x,x,59,x,31,19"
)
real_input <- readLines('input.txt')

# Helper function, given the lines from the input file `input`, 
# returns a list containing the departure time and a list of the
# bus schedules ([7, 13, 59, 31, 19] from the test input)
parse_input <- function(input) {
  depart_time <- as.numeric(input[1])
  bus_schedule <- as.numeric(strsplit(input[2], ',[x,]*')[[1]])
  list(depart_time = depart_time, bus_schedule = bus_schedule)
}


# Helper function, given your desired departure time `depart_time` and a bus's
# schedule `bus_interval`, returns the 'timestamp' of that bus's next arrival
# time immediately following `depart_time`, vectorized
get_next_arrival_time <- function(depart_time, bus_interval) {
  ceiling(depart_time/bus_interval)*bus_interval
}


# Helper function, given your desired departure time `depart_time` and a bus's
# schedule `bus_interval`, returns the time between `depart_time` and the 
# bus's next arrival 'timestamp', vectorized
get_wait_time <- function(depart_time, bus_interval) {
  next_arrival <- get_next_arrival_time(depart_time, bus_interval)
  next_arrival - depart_time
}


notes <- parse_input(real_input)  # Parse the input

# Calculate the wait time for all buses
wait_time <- get_wait_time(notes$depart_time, notes$bus_schedule)
next_bus <- notes$bus_schedule[which.min(wait_time)]  # The bus with shortest wait
answer1 <- next_bus * min(wait_time)

