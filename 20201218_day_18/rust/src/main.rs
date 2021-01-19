mod fileio;
mod part_one;
mod part_two;

use fileio::Expression;
use std::time::Instant;

// Timing function, given the function to run and the input arguments, runs
// the function with the given input and prints the time to run to the
// console
fn time_it(f: fn(&Vec<Expression>) -> (), exprs: &Vec<Expression>) {
    let start = Instant::now();
    f(exprs);
    println!("Solved in: {:?}\n", start.elapsed());
}

fn main() {
    println!("\n--- Advent of Code 2020, Day 18 ---\n");

    let parse_start = Instant::now();
    let input = fileio::read_input("../input.txt").ok().unwrap();
    println!("Parsed in {:?}\n", parse_start.elapsed());

    time_it(part_one::solve, &input); // 131076645626
    time_it(part_two::solve, &input); // 109418509151782
}
