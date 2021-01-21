use crate::tile::Tile;

/// Helper function, given a coordinate and a reference to the full image, checks the
/// image for a sea monster where the tip of the sea monster's tail is at `coordinate`.
pub fn is_sea_monster(coord: (isize, isize), full_img: &Tile) -> bool {
    #[rustfmt::skip]
    let monster_index_offsets = [
        ( 0, 0),  (1, 1),  (1, 4),  (0, 5),
        ( 0, 6),  (1, 7),  (1, 10), (0, 11),
        ( 0, 12), (1, 13), (1, 16), (0, 17),
        (-1, 18), (0, 18), (0, 19)
    ];

    for offset in &monster_index_offsets {
        let idx = ((coord.0 + offset.0) as usize, (coord.1 + offset.1) as usize);
        if !full_img.pixels[idx.0][idx.1] {
            return false;
        }
    }

    true
}

/// Solver for the second part of Day 20
pub fn solve(tile_map: &[Vec<Tile>]) {
    // Prepare a 2D vector to house the pixels extracted from the Tiles
    let full_img_dim = tile_map.len() * 8;
    let spacing = (8, 8);
    let mut full_img = vec![vec![false; full_img_dim]; full_img_dim];

    // For each Tile in the tile_map, need to place the pixels (excluding the outer edges
    // of the tile) into the full image. Their location can be derived from the location
    // of the tile in the tile map and the location of the pixel in the tile.
    for (i, tile_map_row) in tile_map.iter().enumerate() {
        for (j, tile) in tile_map_row.iter().enumerate() {
            // Get the offsets based on the tile location in the tile map, will indicate
            // the upper left corner of the tile in the full image
            let pixels = &tile.pixels;
            let tile_offset = (spacing.0 * i, spacing.1 * j);

            for (ii, pixel_row) in pixels[1..9].iter().enumerate() {
                for (jj, pixel) in pixel_row[1..9].iter().enumerate() {
                    // Transfer each pixel to the full_img map, offset by the pixel's location
                    // within the Tile
                    let pixel_offset = (tile_offset.0 + ii, tile_offset.1 + jj);
                    full_img[pixel_offset.0][pixel_offset.1] = *pixel;
                }
            }
        }
    }

    // Because we're only looking for the tip of the sea monster's tail, restrict the
    // searchable area of the full image to only those coordinates that could contain
    // the tip of a full sea monster's tail.
    let mut full_img_tile = Tile::from_pixels(0, full_img);
    let search_height = 1..full_img_dim - 1;
    let search_width = 0..full_img_dim - 19;
    let mut searchable_coords = Vec::with_capacity(search_height.len() * search_width.len());
    for r in search_height {
        for c in search_width.clone() {
            searchable_coords.push((r as isize, c as isize));
        }
    }

    // Iterate the full image through all possible flips/rotations, then check each
    // permutation for sea monsters. If one sea monster is found, then we know the
    // image is properly oriented
    let oriented_tile = 'outer: loop {
        for coord in &searchable_coords {
            if is_sea_monster(*coord, &full_img_tile) {
                break 'outer full_img_tile;
            }
        }
        full_img_tile = full_img_tile.next().unwrap();
    };

    // Count the sea monsters
    let mut sea_monsters = 0;
    for coord in searchable_coords {
        if is_sea_monster(coord, &oriented_tile) {
            sea_monsters += 1;
        }
    }

    // Count the total number of pixels (spaces in the original image where char == '#')
    let mut pixel_count = 0;
    for row in oriented_tile.pixels {
        for pixel in row {
            if pixel {
                pixel_count += 1
            }
        }
    }

    // The answer is the total number of pixels ('#') minus the number of pixels contained
    // in sea monsters
    let answer = pixel_count - (sea_monsters * 15);
    println!("\nThe answer to part two is {}", answer);
}
