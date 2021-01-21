use crate::tile::{Side, Tile};
use std::cell::RefCell;

#[rustfmt::skip]
pub fn solve(tiles: &[Tile]) -> Vec<Vec<Tile>> {
    //! Solver for the first part of Day 20
    
    // Set up a 'match_map', a 2D vector to house the Tiles in their proper, relative orientation
    let grid_size = ((tiles.len() as f64).sqrt() as usize * 2) - 1;
    let center = grid_size / 2;
    let mut match_map = vec![vec![RefCell::new(None::<Tile>); grid_size]; grid_size];
    let mut match_map_indices = Vec::with_capacity(grid_size * grid_size);
    for row in 0..grid_size {
        for col in 0..grid_size {
            match_map_indices.push((row, col));
        }
    }

    // Note, Tiles can conceptually be in three different 'states': unmatched, matched, or checked
    // An 'unmatched' tile is one that hasn't been placed in the match_map yet, and is derived
    // from comparing the 'tiles' variable to the 'matched_tile_ids' list
    // A 'matched' tile is one that has been placed on the match_map, but hasn't been checked 
    // for neighbors
    // A 'checked' tile is one on the match_map that has been compared against the list of 
    // remaining 'unmatched' tiles in an attempt to place it's neighbors on the board. These Tiles
    // can be ignored in subsequent iterations, they're essentially 'done'.

    // Start with an empty Vec of matched tile ids and checked_indices, place the first
    // Tile in tiles in the center of the match_map as a seed and start checking with
    // that Tile
    let mut matched_tile_ids = Vec::with_capacity(tiles.len());
    let mut checked_indices: Vec<(usize, usize)> = Vec::with_capacity(tiles.len());
    let seed = tiles[0].id;
    match_map[center][center] = RefCell::new(Some(tiles[0].clone()));
    matched_tile_ids.push(seed);

    // Each round, check the tiles in the match_map that haven't been checked for neighbors
    // yet. When you find one, place it into the match_map in the proper space and orientation.
    // Add the indices of the checked tiles to `checked_indices`, so you don't check the same
    // Tile more than once. Repeat until all the Tiles have been placed on the match_map.
    while matched_tile_ids.len() < tiles.len() {
        let indices_to_check: Vec<&(usize, usize)> = match_map_indices
            .iter()
            .filter(|x| !match_map[x.0][x.1].borrow().is_none())
            .filter(|x| !checked_indices.contains(x))
            .collect();
        
        for idx in indices_to_check {
            // It's important that the current_tile after the first run come from the match_map
            // and not the `tiles` vector, since Tiles in the match_map are in their proper 
            // orientation relative to the Tile they were matched against.
            let match_map_current_tile = match_map[idx.0][idx.1].borrow();
            let current_tile = match_map_current_tile.as_ref().unwrap();

            // Check on each side of the current tile. Continue early if attempting to check
            // a space outside the bounds of the match_map
            for side in &[Side::Top, Side::Right, Side::Bottom, Side::Left] {
                let tidx = match side {
                    Side::Top => {
                        if idx.0 == 0 { continue; }
                        (idx.0 - 1, idx.1)
                    },
                    Side::Right => {
                        if idx.1 + 1 == grid_size { continue; }
                        (idx.0, idx.1 + 1)
                    },
                    Side::Bottom => {
                        if idx.0 + 1 == grid_size { continue; }
                        (idx.0 + 1, idx.1)
                    },
                    Side::Left => {
                        if idx.1 == 0 { continue; }
                        (idx.0, idx.1 - 1)
                    },
                };

                // Only if the space is empty...
                if match_map[tidx.0][tidx.1].borrow().is_none() {
                    // Get the list of unmatched tiles and check them to see if they can be
                    // manipulated to fit in the given space.
                    let unmatched_tiles: Vec<&Tile> = tiles
                        .iter()
                        .filter(|x| !matched_tile_ids.contains(&x.id))
                        .collect();

                    let matching_tile = current_tile.find_tile_match(side, &unmatched_tiles);

                    // If a match is found, add the Tile ID to `matched_tile_ids` and add the 
                    // Tile to the match_map, in the proper orientation.
                    if let Some(tile) = matching_tile {
                        let found_tile_id = tile.id;
                        matched_tile_ids.push(found_tile_id);

                        let mut match_map_space = match_map[tidx.0][tidx.1].borrow_mut();
                        match_map_space.replace(tile);
                    }
                }
            }

            checked_indices.push(*idx); // So we don't check this one again
        }
    }

    // Since the original match_map was made large enough to hold all the tiles no matter
    // how they were placed, we need to extract the actual Tiles and discard the blank
    // spaces (indicated by None)
    let mut cropped_tile_map = Vec::with_capacity(16);
    for row in match_map {
        let mut cropped_tile_row = Vec::with_capacity(16);
        for col in row {
            let value = col.borrow();
            match (*value).clone() {
                Some(tile) => cropped_tile_row.push(tile),
                None => continue,
            }
        }
        if cropped_tile_row.len() > 0 { cropped_tile_map.push(cropped_tile_row) };
    }

    // Now that we have a 2D vector of Tiles, just get the corner ID's
    let size = cropped_tile_map.len() - 1;
    let corner1 = cropped_tile_map[0][0].id as u64;
    let corner2 = cropped_tile_map[0][size].id as u64;
    let corner3 = cropped_tile_map[size][0].id as u64;
    let corner4 = cropped_tile_map[size][size].id as u64;

    let answer = corner1 * corner2 * corner3 * corner4;
    println!("\nThe answer to part one is {}", answer);

    cropped_tile_map  // Return for use in Part Two
}
