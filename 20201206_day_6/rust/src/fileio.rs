use std::collections::HashSet;
use std::fs::File;
use std::io::{BufRead, BufReader, Error};

// Function to read in lines from an input file and convert them to a Vec<String>
pub fn read_input(filename: &str) -> Result<Vec<Vec<HashSet<char>>>, Error> {
    let file = File::open(&filename)?; // Open file or panic
    let br = BufReader::new(file); // Create read buffer
    let mut v = vec![]; // Initialize empty vector

    // For each line in the input file...
    let mut group = vec![];
    for line in br.lines() { 
        let line_string = line?.trim().to_string();
        if line_string.is_empty() {
            v.push(group);
            group = vec![]
        } else {
            let mut person = HashSet::new();
            for c in line_string.chars() {
                person.insert(c);
            }
            group.push(person);
        }
    }
    v.push(group); // Get the last group

    return Ok(v); // Return data
}
