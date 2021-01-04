use std::collections::HashMap;
use std::fs::File;
use std::io::{BufRead, BufReader, Error};

// Function to take a bag string like "1 bright white bag" and return a tuple 
// ("bright white bag", 1)
fn parse_bag_string(string: &str) -> (String, u32) {
    let mut bag_value: Option<u32> = None;

    // Start and end indices for the bag name
    let mut name_start = 0;
    let mut name_end = 0;

    // For each enumerated character in `string`...
    for (i, c) in string.chars().enumerate() {

        // If it's a digit, that's the value. Depends on the input not having more than 9 bags
        // nested in another bag (true for the puzzle input).
        if c.is_digit(10) {
            bag_value = Some(c.to_digit(10).unwrap());
        }

        // The first real letter is the start of the name
        if name_start == 0 && c.is_ascii_alphabetic() {
            name_start = i;
        }

        // The character where the next 4 characters == " bag" helps us find the last letter
        // of the name
        if c == ' ' && &string[i..i+4] == " bag" {
            name_end = i+4;
            break;
        }
    }

    // Use the indices to extract the name of the bag
    let bag_name = string[name_start..name_end].to_string();

    // Return the tuple, assuming we could parse the string
    match bag_value {
        Some(x) => (bag_name, x),
        None => panic!("Could not parse bag string {}", string),
    }
}

// Function to read in lines from an input file and convert them to a Vec<String>
pub fn read_input(filename: &str) -> Result<HashMap<String, HashMap<String, u32>>, Error> {
    let file = File::open(&filename)?; // Open file or panic
    let br = BufReader::new(file); // Create read buffer

    let mut hm: HashMap<String, HashMap<String, u32>> = HashMap::new();

    // For each line in the input file...
    for line in br.lines() { 
        let line_string = line?.trim().to_string();
        let mut key: Option<&str> = None;
        let mut values: HashMap<String, u32> = HashMap::new();

        // Split the line on "s contain ". This should yield two parts, the first part is the key
        // to the HashMap, the second part contains the info to parse into the value. If the
        // second part is the string "no other bags.", then the value will be an empty 
        // HashMap<String, u32>. Otherwise, split the second part on ", ", and parse each of
        // those parts into a HashMap<String, u32> where each key is a bag name and the value is
        // the number of those bags indicated.
        for (i, s1) in line_string.split("s contain ").enumerate() {
            if i == 0 { 
                key = Some(s1);
                continue;
            } 
            if s1 == "no other bags." { continue; }
            for s2 in s1.split(", ") {
                let parsed = parse_bag_string(s2);
                values.insert(parsed.0, parsed.1);
            }
        }
        
        // Assuming we got a key out, add an entry to `hm` for that line
        match key {
            None => panic!("Could not parse key from {:?}", line_string),
            Some(x) => { hm.insert(x.to_string(), values); },
        }
    }

    return Ok(hm); // Return data
}
