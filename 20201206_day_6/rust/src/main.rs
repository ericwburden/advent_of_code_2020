mod fileio;
mod part_one;
mod part_two;

use std::collections::HashSet;
use std::time::Instant;

// Timing function, given the function to run and the input arguments, runs
// the function with the given input and prints the time to run to the
// console
fn time_it(f: fn(&Vec<Vec<HashSet<char>>>) -> (), group_answers: &Vec<Vec<HashSet<char>>>) {
    let start = Instant::now();
    f(&group_answers);
    let duration = start.elapsed();

    println!("Solved in: {:?}\n", duration);
}

fn main() {
    // Read and parse the input file
    let input = match fileio::read_input("../input.txt") {
        Ok(x) => x,
        Err(e) => panic!("Error: {}", e),
    };

    time_it(part_one::sum_answer_counts, &input); // 6291
    time_it(part_two::sum_answer_counts, &input); // 3052
}
