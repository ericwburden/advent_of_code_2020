mod input;
mod part_one;
mod part_two;

use input::Input;
use std::time::Instant;

fn main() {
    println!("\n--- Advent of Code 2020, Day 16 ---\n");
    let part_one_start = Instant::now();
    let input = Input::from_file("../input.txt").ok().unwrap();
    let invalid_fields = part_one::solve(&input); // 32842
    println!("Part one completed in {:?}\n", part_one_start.elapsed());

    let part_two_start = Instant::now();
    part_two::solve(&input, &invalid_fields); // 2628667251989
    println!("Part two completed in {:?}\n", part_two_start.elapsed());
}
