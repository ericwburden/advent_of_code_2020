// --- Day 2: Password Philosophy ---
//
// Your flight departs in a few days from the coastal airport; the easiest way
// down to the coast from here is via toboggan.
//
// The shopkeeper at the North Pole Toboggan Rental Shop is having a bad day.
// "Something's wrong with our computers; we can't log in!" You ask if you can
// take a look.
//
// Their password database seems to be a little corrupted: some of the passwords
// wouldn't have been allowed by the Official Toboggan Corporate Policy that was
// in effect when they were chosen.
//
// To try to debug the problem, they have created a list (your puzzle input) of
// passwords (according to the corrupted database) and the corporate policy when
// that password was set.
//
// For example, suppose you have the following list:
//
// ```
// 1-3 a: abcde
// 1-3 b: cdefg
// 2-9 c: ccccccccc
// ```
//
// Each line gives the password policy and then the password. The password
// policy indicates the lowest and highest number of times a given letter must
// appear for the password to be valid. For example, 1-3 a means that the
// password must contain a at least 1 time and at most 3 times.
//
// In the above example, 2 passwords are valid. The middle password, `cdefg`,
// is not; it contains no instances of b, but needs at least 1. The first and
// third passwords are valid: they contain one a or nine c, both within the
// limits of their respective policies.
//
// How many passwords are valid according to their policies?

// --- Part Two ---
//
// While it appears you validated the passwords correctly, they don't seem to
// be what the Official Toboggan Corporate Authentication System is expecting.
//
// The shopkeeper suddenly realizes that he just accidentally explained the
// password policy rules from his old job at the sled rental place down the
// street! The Official Toboggan Corporate Policy actually works a little
// differently.
//
// Each policy actually describes two positions in the password, where 1 means
// the first character, 2 means the second character, and so on. (Be careful;
// Toboggan Corporate Policies have no concept of "index zero"!) Exactly one of
// these positions must contain the given letter. Other occurrences of the
// letter are irrelevant for the purposes of policy enforcement.
//
// Given the same example list from above:
//
//  - `1-3 a: abcde` is valid: position 1 contains a and position 3 does not.
//  - `1-3 b: cdefg` is invalid: neither position 1 nor position 3 contains b.
//  - `2-9 c: ccccccccc` is invalid: both position 2 and position 9 contain c.
//
// How many passwords are valid according to the new interpretation of the
// policies?

use std::fs::File;
use std::io::{BufRead, BufReader, Error};
use std::time::Instant;

// Read in the input file as a Vec<String>
fn read_input(filename: &str) -> Result<Vec<String>, Error> {
    let file = File::open(&filename)?; // Open file or panic
    let br = BufReader::new(file); // Create read buffer
    let mut v = vec![]; // Initialize empty vector

    // For each line in the buffered reader, read the contents to an i32 and
    // push to `v`. Panic if no line is found.
    for line in br.lines() {
        v.push(String::from(line?.trim()));
    }

    return Ok(v); // Return data
}

// Struct to hold the structured data from each line of the input file
#[derive(Debug)]
struct PasswordLine {
    number1: usize,   // The first number in the password rule
    number2: usize,   // The second number in the password rule
    test_char: char,  // The character in the password rule
    password: String, // The password
}

impl PasswordLine {
    // Tests the password for validity according to the part one rules
    fn part_one_valid(&self) -> bool {
        let mut test_chars_found = 0;
        for c in self.password.chars() {
            if c == self.test_char {
                test_chars_found += 1;
            }
        }
        self.number1 <= test_chars_found && test_chars_found <= self.number2
    }

    // Tests the password for validity according to the part two rules
    fn part_two_valid(&self) -> bool {
        let char_at_n1 = self.password.as_bytes()[self.number1 - 1] as char;
        let char_at_n2 = self.password.as_bytes()[self.number2 - 1] as char;
        let number1_match = self.test_char == char_at_n1;
        let number2_match = self.test_char == char_at_n2;

        if number1_match {
            return !number2_match;
        }
        if number2_match {
            return !number1_match;
        }
        return false;
    }
}

// Parse the Strings from the input file into a Vec of PasswordLines
fn parse_input_lines(input_lines: &Vec<String>) -> Vec<PasswordLine> {
    let mut password_lines = vec![];

    // For each line in the input...
    for input_line in input_lines.iter() {
        let mut dash = 0; // Position of dash character
        let mut first_space = 0; // Position of first space character
        let mut colon = 0; // Position of colon character
        let mut second_space = 0; // Position of second space character

        // Find the positions of the marker characters in the input line
        for (i, c) in input_line.chars().enumerate() {
            if c == ' ' && first_space != 0 {
                second_space = i;
                break;
            }
            if c == '-' {
                dash = i;
            }
            if c == ' ' && first_space == 0 {
                first_space = i;
            }
            if c == ':' {
                colon = i;
            }
        }

        // Given the locations of the marker characters, parse out the
        // components of the PasswordLine
        let number1 = match input_line[0..dash].parse::<usize>() {
            Ok(x) => x,
            Err(_) => panic!("Could not parse number1 from {}", input_line),
        };

        let number2 = match input_line[(dash + 1)..first_space].parse::<usize>() {
            Ok(x) => x,
            Err(_) => panic!("Could not parse number2 from {}", input_line),
        };

        let test_char = match input_line[(first_space + 1)..colon].parse::<char>() {
            Ok(x) => x,
            Err(_) => panic!("Could not parse test_char from {}", input_line),
        };

        let password = input_line[(second_space + 1)..].to_string();

        let password_line = PasswordLine {
            number1,
            number2,
            test_char,
            password,
        };
        password_lines.push(password_line);
    }

    return password_lines;
}

// Count up the number of `password_lines` that contain a valid password
// according to the part one rules
fn part_one(password_lines: &Vec<PasswordLine>) {
    let valid_passwords = password_lines
        .iter()
        .map(|x| x.part_one_valid())
        .fold(0, |total, next| total + if next { 1 } else { 0 });

    println!("\n{} valid passwords, part one.", valid_passwords);

    // Answer: 607
}

// Count up the number of `password_lines` that contain a valid password
// according to the part two rules
fn part_two(password_lines: &Vec<PasswordLine>) {
    let valid_passwords = password_lines
        .iter()
        .map(|x| x.part_two_valid())
        .fold(0, |total, next| total + if next { 1 } else { 0 });

    println!("\n{} valid passwords, part two.", valid_passwords);

    // Answer: 321
}

// Timing function, given the function to run and the input arguments, runs
// the function with the given input and prints the time to run to the
// console
fn time_it(f: fn(&Vec<PasswordLine>) -> (), password_lines: &Vec<PasswordLine>) {
    let start = Instant::now();
    f(password_lines);
    let duration = start.elapsed();

    println!("Solved in: {:?}\n", duration);
}

fn main() {
    // Read in input data
    let input_data = match read_input("../input.txt") {
        Ok(data) => data,
        Err(_) => panic!("Could not read input file."),
    };

    // Parse into structured content
    let password_lines = parse_input_lines(&input_data);

    // Check password validity according to puzzle rules
    time_it(part_one, &password_lines);
    time_it(part_two, &password_lines);
}
