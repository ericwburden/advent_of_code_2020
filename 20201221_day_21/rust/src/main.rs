mod fileio;
mod part_one;
mod part_two;
mod recipe;

use std::time::Instant;

fn main() {
    println!("\n--- Advent of Code 2020, Day 21 ---\n");

    let parse_start = Instant::now();
    let all_recipes = fileio::read_input("../input.txt").ok().unwrap();
    println!("Parsed in {:?}", parse_start.elapsed());

    let part_one_start = Instant::now();
    let possible_allergen_ingredients = part_one::solve(all_recipes);
    println!("Solved in {:?}\n", part_one_start.elapsed());

    let part_two_start = Instant::now();
    part_two::solve(&possible_allergen_ingredients);
    println!("Solved in {:?}\n", part_two_start.elapsed());
}
