#' **--- Part Two ---**
#'   
#' For some reason, the sea port's computer system still can't communicate with 
#' your ferry's docking program. It must be using version 2 of the decoder chip!
#' 
#' A version 2 decoder chip doesn't modify the values being written at all. 
#' Instead, it acts as a memory address decoder. Immediately before a value is 
#' written to memory, each bit in the bitmask modifies the corresponding bit of 
#' the destination memory address in the following way:
#'   
#' If the bitmask bit is 0, the corresponding memory address bit is unchanged.
#' If the bitmask bit is 1, the corresponding memory address bit is overwritten 
#' with 1.
#' If the bitmask bit is X, the corresponding memory address bit is floating.
#' 
#' A floating bit is not connected to anything and instead fluctuates 
#' unpredictably. In practice, this means the floating bits will take on all 
#' possible values, potentially causing many memory addresses to be written all 
#' at once!
#'   
#' For example, consider the following program:
#'   
#' mask = 000000000000000000000000000000X1001X
#' mem[42] = 100
#' mask = 00000000000000000000000000000000X0XX
#' mem[26] = 1
#' 
#' When this program goes to write to memory address 42, it first applies the 
#' bitmask:
#'   
#' address: 000000000000000000000000000000101010  (decimal 42)
#' mask:    000000000000000000000000000000X1001X
#' result:  000000000000000000000000000000X1101X
#' 
#' After applying the mask, four bits are overwritten, three of which are 
#' different, and two of which are floating. Floating bits take on every 
#' possible combination of values; with two floating bits, four actual memory 
#' addresses are written:
#'   
#' 000000000000000000000000000000011010  (decimal 26)
#' 000000000000000000000000000000011011  (decimal 27)
#' 000000000000000000000000000000111010  (decimal 58)
#' 000000000000000000000000000000111011  (decimal 59)
#' 
#' Next, the program is about to write to memory address 26 with a different 
#' bitmask:
#'   
#' address: 000000000000000000000000000000011010  (decimal 26)
#' mask:    00000000000000000000000000000000X0XX
#' result:  00000000000000000000000000000001X0XX
#' 
#' This results in an address with three floating bits, causing writes to eight 
#' memory addresses:
#'   
#' 000000000000000000000000000000010000  (decimal 16)
#' 000000000000000000000000000000010001  (decimal 17)
#' 000000000000000000000000000000010010  (decimal 18)
#' 000000000000000000000000000000010011  (decimal 19)
#' 000000000000000000000000000000011000  (decimal 24)
#' 000000000000000000000000000000011001  (decimal 25)
#' 000000000000000000000000000000011010  (decimal 26)
#' 000000000000000000000000000000011011  (decimal 27)
#' 
#' The entire 36-bit address space still begins initialized to the value 0 at 
#' every address, and you still need the sum of all values left in memory at 
#' the end of the program. In this example, the sum is 208.
#' 
#' Execute the initialization program using an emulator for a version 2 decoder 
#' chip. What is the sum of all values left in memory after it completes?
  
source('exercise_1.R')

test_input2 <- c(
  "mask = 000000000000000000000000000000X1001X",
  "mem[42] = 100",
  "mask = 00000000000000000000000000000000X0XX",
  "mem[26] = 1"
)


# Given a string `s` in the format "mask = 000000000000000000000000000000X1001X",
# return a character matrix where each row represents a mask to apply.
to_mask <- function(s) {
  mask_chars <- unlist(str_split(str_extract(s, '\\b[X\\d]+$'), ''))
  matrix(unlist(all_masks(mask_chars)), ncol = 36, byrow = T)
}


# Given a character vector consisting of 1's, 0's and X's `chars` (the `i`
# argument should be ignored, it's used for the recursion), return a list
# containing all possible interpretations of the mask
all_masks <- function(chars, i = 1) {
  if (i > length(chars)){ return(chars) }
  if (chars[i] == 'X') {
    chars[i] <- 'Z'; chars0 <- chars
    chars[i] <- '1'; chars1 <- chars
    list(all_masks(chars0, i + 1), all_masks(chars1, i + 1))
  } else {
    all_masks(chars, i + 1)
  }
}


# Given a character vector representing a bit mask to apply `mask` and a 
# 'binary' vector `vec`, return a binary vector representing the result of 
# applying the mask to the 'binary' vector
apply_mask <- function(mask, vec) {
  vec[which(mask == '1')] <- 1
  vec[which(mask == 'Z')] <- 0
  vec
}


input <- real_input  # The input
output <- list()     # List to hold output

# For each line in the input...
for (line in input) {
  type <- str_extract(line, '^\\w+')             # Get the 'type'
  if (type == 'mask') { masks <- to_mask(line)}  # 'mask' type to mask matrix
  if (type == 'mem') {
    # `address` is the number between the brackets
    address <- as.numeric(str_extract(line, '(?<=\\[)\\d+(?=\\])'))
    address_bits <- to_bits(address)
    value <- as.numeric(str_extract(line, '\\d+$'))  # Numbers after `=`
    
    # For each mask (row) in the mask matrix...
    for (r in seq(nrow(masks))) {
      # Mask the `address_bits`, convert it to a character representation of
      # the numeric value, then use that character representation as the name
      # of the list item to assign `value` to. Some of these list items
      # may be overwritten by subsequent iterations.
      masked_address_bits <- apply_mask(masks[r,], address_bits)
      masked_address <- as.character(to_numeric(masked_address_bits))
      output[[masked_address]] <- value
    }
  }
}
answer2 <- sum(unlist(output))


# Answer:3219837697833








