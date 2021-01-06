use std::fs::File;
use std::io::{BufRead, BufReader, Error, ErrorKind};

// Function to read in lines from an input file and convert them to a Vec<usize>
pub fn read_input(filename: &str) -> Result<Vec<usize>, Error> {
    let file = File::open(&filename)?; // Open file or panic
    let br = BufReader::new(file); // Create read buffer
    let mut v = vec![]; // Initialize empty vector

    // For each line in the input file...
    for line in br.lines() {
        v.push(
            line?
                .trim()
                .parse()
                .map_err(|e| Error::new(ErrorKind::InvalidData, e))?,
        );
    }

    return Ok(v); // Return data
}
