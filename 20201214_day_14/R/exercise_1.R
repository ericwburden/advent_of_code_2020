#' **--- Day 14: Docking Data ---**
#'   
#' As your ferry approaches the sea port, the captain asks for your help again. 
#' The computer system that runs this port isn't compatible with the docking 
#' program on the ferry, so the docking parameters aren't being correctly 
#' initialized in the docking program's memory.
#' 
#' After a brief inspection, you discover that the sea port's computer system 
#' uses a strange bitmask system in its initialization program. Although you 
#' don't have the correct decoder chip handy, you can emulate it in software!
#' 
#' The initialization program (your puzzle input) can either update the bitmask 
#' or write a value to memory. Values and memory addresses are both 36-bit 
#' unsigned integers. For example, ignoring bitmasks for a moment, a line like 
#' mem[8] = 11 would write the value 11 to memory address 8.
#' 
#' The bitmask is always given as a string of 36 bits, written with the most 
#' significant bit (representing 2^35) on the left and the least significant 
#' bit (2^0, that is, the 1s bit) on the right. The current bitmask is applied 
#' to values immediately before they are written to memory: a 0 or 1 overwrites 
#' the corresponding bit in the value, while an X leaves the bit in the value 
#' unchanged.
#' 
#' For example, consider the following program:
#' 
#' mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
#' mem[8] = 11
#' mem[7] = 101
#' mem[8] = 0
#' 
#' This program starts by specifying a bitmask (mask = ....). The mask it 
#' specifies will overwrite two bits in every written value: the 2s bit is 
#' overwritten with 0, and the 64s bit is overwritten with 1.
#' 
#' The program then attempts to write the value 11 to memory address 8. By 
#' expanding everything out to individual bits, the mask is applied as follows:
#' 
#' value:  000000000000000000000000000000001011  (decimal 11)
#' mask:   XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
#' result: 000000000000000000000000000001001001  (decimal 73)
#' 
#' So, because of the mask, the value 73 is written to memory address 8 instead. 
#' Then, the program tries to write 101 to address 7:
#' 
#' value:  000000000000000000000000000001100101  (decimal 101)
#' mask:   XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
#' result: 000000000000000000000000000001100101  (decimal 101)
#' 
#' This time, the mask has no effect, as the bits it overwrote were already the 
#' values the mask tried to set. Finally, the program tries to write 0 to 
#' address 8:
#' 
#' value:  000000000000000000000000000000000000  (decimal 0)
#' mask:   XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
#' result: 000000000000000000000000000001000000  (decimal 64)
#' 
#' 64 is written to address 8 instead, overwriting the value that was there 
#' previously.
#' 
#' To initialize your ferry's docking program, you need the sum of all values 
#' left in memory after the initialization program completes. (The entire 
#' 36-bit address space begins initialized to the value 0 at every address.) In 
#' the above example, only two values in memory are not zero - 101 (at address 
#' 7) and 64 (at address 8) - producing a sum of 165.
#' 
#' Execute the initialization program. What is the sum of all values left in 
#' memory after it completes?

test_input <- c(
  "mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X",
  "mem[8] = 11",
  "mem[7] = 101",
  "mem[8] = 0"
)

real_input <- readLines('../input.txt')

library(stringr)  # For str_split(), str_extract()


# Given a number `n`, returns a numeric representation of the 36 consituent bits
to_bits <- function(n) {
  bits <- as.numeric(intToBits(n))
  c(rep(0, 4), rev(bits))
}


# Given a binary vector `bin_vec` as produced by `to_bits()`, return the
# decimal value
to_numeric <- function(bin_vec) {
  places <- (length(bin_vec):1) - 1
  sum(2^places[which(bin_vec == 1)])
}


# Given a string `s` in the form of 'mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X',
# return the part to the right of the `=` sign as a character vector
to_mask <- function(s) {
  str_split(str_extract(s, '\\b[X\\d]+$'), '', simplify = T)
}


# Given a binary vector `bits`, the bits vector after applying a mask 
# `masked_bits`, and the numeric representation of the masked bits `result`,
# returns a named list containing those items
output_el <- function(bits, masked_bits, result) {
  list(bits = bits, masked_bits = masked_bits, result = result)
}

# Given a character vector representing a bit mask `mask` and a vector of 
# bits `vec`, applies the mask to the bit vector as described in the puzzle
# instructions
apply_mask <- function(mask, vec) {
  vec[which(mask != 'X')] <- as.numeric(mask[mask != 'X'])
  vec
}


input <- real_input   # Parse the input
mask <- rep('X', 36)  # A dummy mask
output <- list()      # List to hold the output

# For each line in the input lines
for (line in input) {
  type <- str_extract(line, '^\\w+')  # The 'type' is the word to the left of `=`
  if (type == 'mask') { mask <- to_mask(line)}
  if (type == 'mem') {
    # For 'mem' lines, convert the number to 'bits', apply the mask, convert
    # back to a number, then save the result to the `output` list  with a list
    # item name from the memory address
    address <- str_extract(line, '(?<=\\[)\\d+(?=\\])')
    bits <- to_bits(as.numeric(str_extract(line, '\\d+$')))
    masked_bits <- apply_mask(mask, bits)
    result <- to_numeric(masked_bits)
    output[[address]] <- output_el(bits, masked_bits, result)
  }
}
results <- sapply(output, function(x){ x$result })  # Get all the numeric results
answer1 <- sum(results)
