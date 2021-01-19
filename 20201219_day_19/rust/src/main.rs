mod fileio;
mod part_one;
mod part_two;

use std::time::Instant;

fn main() {
    println!("\n--- Advent of Code 2020, Day 19 ---\n");

    let parse_start = Instant::now();
    let (mut rules, messages) = fileio::read_input("../input.txt").ok().unwrap();
    println!("Parsed in {:?}", parse_start.elapsed());

    let part_one_start = Instant::now();
    part_one::solve(&rules, &messages);
    println!("Solved in {:?}\n", part_one_start.elapsed());

    let part_two_start = Instant::now();
    part_two::solve(&mut rules, &messages);
    println!("Solved in {:?}\n", part_two_start.elapsed());
}
