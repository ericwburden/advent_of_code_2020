use crate::instruction::Instruction;
use std::fs::File;
use std::io::{BufRead, BufReader, Error};

// Function to read in lines from an input file and convert them to a Vec<Instruction>
pub fn read_input(filename: &str) -> Result<Vec<Instruction>, Error> {
    let file = File::open(&filename)?; // Open file or panic
    let br = BufReader::new(file); // Create read buffer
    let mut v = vec![]; // Initialize empty vector

    // For each line in the input file...
    for line in br.lines() {
        let line_string = line?.trim().to_string();
        let instruction = Instruction::from_string(&line_string);
        v.push(instruction);
    }

    return Ok(v); // Return data
}
