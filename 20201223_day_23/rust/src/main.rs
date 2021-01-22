mod part_one;
mod part_two;
mod part_twob;

use std::time::Instant;

fn main() {
    let part_one_start = Instant::now();
    part_one::solve();
    println!("Solved in {:?}\n", part_one_start.elapsed());

    let part_two_start = Instant::now();
    part_two::solve();
    println!("Solved in {:?}\n", part_two_start.elapsed());

    let part_twob_start = Instant::now();
    part_twob::solve();
    println!("Solved in {:?}\n", part_twob_start.elapsed());
}
