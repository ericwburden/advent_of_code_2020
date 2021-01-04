use std::fs::File;
use std::io::{BufRead, BufReader, Error};

// Function to read in lines from an input file and convert them to a 
// Vec<String>, collapses each set of fields to a single String
pub fn read_input(filename: &str) -> Result<Vec<String>, Error> {
    let file = File::open(&filename)?; // Open file or panic
    let br = BufReader::new(file); // Create read buffer
    let mut v = vec![]; // Initialize empty vector

    let mut i = 0; // Current Vec element to add to
    v.push(String::new());

    // For each line in the input file...
    for line in br.lines() {
        let line_string = line?.trim().to_string();

        // If the line is an empty string, start pushing lines to a new String,
        // otherwise, continue pushing lines to the current vector element. This
        // puts all the lines for a single passport into a single String.
        if line_string.is_empty() {
            v.push(String::new());
            i += 1;
        } else {
            v[i].push_str(&line_string);
            v[i].push_str(" ");
        }
    }

    return Ok(v); // Return data
}
