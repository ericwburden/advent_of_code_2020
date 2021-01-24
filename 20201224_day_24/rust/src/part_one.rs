use crate::offset::Offset;
use std::collections::HashSet;

pub fn solve(tiles: &mut HashSet<Offset>, offsets: Vec<Offset>) {
    for offset in offsets {
        if !tiles.insert(offset) {
            tiles.remove(&offset);
        }
    }

    println!("\nThe answer to part one is {}", tiles.len());
}
