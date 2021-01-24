use crate::offset::Offset;
use std::collections::{HashMap, HashSet};

pub fn solve(tiles: &mut HashSet<Offset>) {
    for _ in 1..=100 {
        let mut neighbor_counts: HashMap<Offset, u8> = HashMap::new();
        for tile in tiles.iter() {
            for neighbor in tile.neighbors() {
                let count = neighbor_counts.entry(neighbor).or_insert(0);
                *count += 1;
            }
        }

        let mut new_tiles = HashSet::new();
        for (coord, count) in &neighbor_counts {
            if *count == 2 || (*count == 1 && tiles.contains(coord)) {
                new_tiles.insert(*coord);
            }
        }
        *tiles = new_tiles;
    }

    println!("\nThe answer to part two is {}", tiles.len());
}
