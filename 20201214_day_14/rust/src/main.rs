mod bit_array;
mod bit_mask;
mod instruction;
mod memory_registry;
mod part_one;
mod part_two;

use std::io::Error;
use std::time::Instant;

// Timing function, given the function to run and the input arguments, runs
// the function with the given input and prints the time to run to the
// console
fn time_it(f: fn(&str) -> Result<(), Error>, filename: &str) {
    let start = Instant::now();
    f(filename).ok();
    println!("Solved in: {:?}\n", start.elapsed());
}

fn main() {
    println!("\n--- Advent of Code: Day 14 ---\n");
    time_it(part_one::solve, "../input.txt"); // 16003257187056
    time_it(part_two::solve, "../input.txt"); // 3219837697833
}
