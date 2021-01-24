mod offset;
mod part_one;
mod part_two;

use offset::Offset;
use std::collections::HashSet;
use std::fs::File;
use std::io::{BufRead, BufReader, Error};
use std::time::Instant;

pub fn read_input(filename: &str) -> Result<Vec<Offset>, Error> {
    let file = File::open(filename)?;
    let br = BufReader::new(file);
    let mut offsets = Vec::new();

    for line in br.lines() {
        offsets.push(Offset::from(line?.trim()));
    }

    Ok(offsets)
}

fn main() {
    let part_one_start = Instant::now();
    let offsets = read_input("../input.txt").ok().unwrap();
    let mut tiles: HashSet<Offset> = HashSet::new();

    part_one::solve(&mut tiles, offsets); // 269
    println!("Solved in {:?}", part_one_start.elapsed());

    let part_two_start = Instant::now();
    part_two::solve(&mut tiles); // 3667
    println!("Solved in {:?}", part_two_start.elapsed());
}
