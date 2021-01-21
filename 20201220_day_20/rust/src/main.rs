mod fileio;
mod part_one;
mod part_two;
mod tile;

use std::time::Instant;

fn main() {
    println!("\n--- Advent of Code 2020, Day 20 ---\n");
    let parse_start = Instant::now();
    let tiles = fileio::read_input("../input.txt").ok().unwrap();
    println!("Input parsed in {:?}", parse_start.elapsed());

    let part_one_start = Instant::now();
    let mapped_tiles = part_one::solve(&tiles); // 7492183537913
    println!("Solved in {:?}", part_one_start.elapsed());

    let part_two_start = Instant::now();
    part_two::solve(&mapped_tiles); // 2323
    println!("Solved in {:?}\n", part_two_start.elapsed());
}
