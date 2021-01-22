mod part_one;
mod part_two;

use std::collections::VecDeque;
use std::time::Instant;

#[rustfmt::skip]
fn main() {
    let player1: VecDeque<u16> = VecDeque::from(vec![
        19, 22, 43, 38, 23, 
        21, 02, 40, 31, 17, 
        27, 28, 35, 44, 41, 
        47, 50, 07, 39, 05, 
        42, 25, 33, 03, 48,
    ]);
    let player2: VecDeque<u16> = VecDeque::from(vec![
        16, 24, 36,  6, 34, 
        11, 08, 30, 26, 15, 
        09, 10, 14, 01, 12, 
        04, 32, 13, 18, 46, 
        37, 29, 20, 45, 49,
    ]);

    println!("\n--- Advent of Code 2020, Day 22 ---");

    // Part One ----------------------------------------------------------------
    let part_one_start = Instant::now();
    let mut p1 = player1.clone();
    let mut p2 = player2.clone();
    part_one::solve(&mut p1, &mut p2);
    println!("Solved in {:?}", part_one_start.elapsed());

    // Part Two ----------------------------------------------------------------
    let part_two_start = Instant::now();
    let mut p1 = player1.clone();
    let mut p2 = player2.clone();
    part_two::solve(&mut p1, &mut p2);
    println!("Solved in {:?}\n", part_two_start.elapsed());
}
