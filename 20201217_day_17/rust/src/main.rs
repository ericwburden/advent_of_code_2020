mod four_dim_grid;
mod three_dim_grid;

use four_dim_grid::FourDimGrid;
use std::fs::File;
use std::io::{BufRead, BufReader, Error};
use std::time::Instant;
use three_dim_grid::ThreeDimGrid;

const CYCLES: usize = 6;

pub fn slice_from_file(filename: &str) -> Result<Vec<Vec<bool>>, Error> {
    let file = File::open(filename)?;
    let br = BufReader::new(file);
    let mut slice = Vec::new();

    for line in br.lines() {
        let line_string = line?;
        let mut slice_row = Vec::new();

        for c in line_string.chars() {
            slice_row.push(c == '#');
        }
        slice.push(slice_row);
    }

    Ok(slice)
}

fn main() {
    let slice = slice_from_file("../input.txt").ok().unwrap();

    let start = Instant::now();
    let mut grid = ThreeDimGrid::from_slice(&slice);
    grid.advance_n_times(6);
    println!("\nCompleted in {:?}", start.elapsed());
    println!("{}", grid.count_active());

    let start = Instant::now();
    let mut grid = FourDimGrid::from_slice(&slice);
    grid.advance_n_times(CYCLES as u8);
    println!("\nCompleted in {:?}", start.elapsed());
    println!("{}\n", grid.count_active());
}
