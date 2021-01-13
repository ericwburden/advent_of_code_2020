use std::fs::File;
use std::io::{BufRead, BufReader, Error};

#[derive(Debug)]
pub struct BusSchedule {
    pub timestamp: usize,
    pub buses: Vec<Option<usize>>,
}

impl BusSchedule {
    pub fn from_file(filename: &str) -> Result<Self, Error> {
        let file = File::open(&filename)?; // Open file or panic
        let br = BufReader::new(file); // Create read buffer
        let mut timestamp: usize = 0;
        let mut buses: Vec<Option<usize>> = Vec::new();

        // For each line in the input file...
        for (i, line) in br.lines().enumerate() {
            let line_string = line?.trim().to_string();
            if i == 0 {
                timestamp = line_string.parse().ok().unwrap();
            } else {
                for n in line_string.split(',') {
                    buses.push(n.parse().ok())
                }
            }
        }

        return Ok(BusSchedule { timestamp, buses }); // Return data
    }
}
