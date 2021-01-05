mod fileio;
mod instruction;
mod part_one;
mod part_two;

use instruction::Instruction;
use std::time::Instant;

// Timing function, given the function to run and the input arguments, runs
// the function with the given input and prints the time to run to the
// console
fn time_it(f: fn(&Vec<Instruction>) -> (), instructions: &Vec<Instruction>) {
    let start = Instant::now();
    f(instructions);
    let duration = start.elapsed();

    println!("Solved in: {:?}\n", duration);
}

fn main() {
    // Read and parse the input file
    let input = match fileio::read_input("../input.txt") {
        Ok(x) => x,
        Err(e) => panic!("Error: {}", e),
    };

    // Run the parts and report the result and time taken
    time_it(part_one::solve, &input); // 1271
    time_it(part_two::solve, &input); // 501
}
