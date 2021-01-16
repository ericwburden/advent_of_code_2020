use crate::CYCLES;

pub struct ThreeDimGrid {
    dimensions: [usize; 3],
    active_range: [(usize, usize); 3],
    state: Vec<Vec<Vec<bool>>>,
    neighbors: Vec<Vec<Vec<Vec<[usize; 3]>>>>,
}

impl ThreeDimGrid {
    pub fn from_slice(slice: &Vec<Vec<bool>>) -> Self {
        let slice_dims = [1, slice[0].len(), slice.len()];
        let dimensions = [
            slice_dims[0] + CYCLES,
            slice_dims[1] + (CYCLES * 2),
            slice_dims[2] + (CYCLES * 2),
        ];

        // The active range is the region larger than the slice by one increment in every
        // dimension. It contains all the cubes that might become active in the next advancement.
        let active_range = [
            (CYCLES, CYCLES + slice_dims[0]),
            (CYCLES, CYCLES + slice_dims[1]),
            (CYCLES, CYCLES + slice_dims[2]),
        ];

        let mut state = vec![vec![vec![false; dimensions[2]]; dimensions[1]]; dimensions[0]];
        for y in (CYCLES)..(CYCLES + slice_dims[1]) {
            for x in (CYCLES)..(CYCLES + slice_dims[2]) {
                state[CYCLES][y][x] = slice[y - CYCLES][x - CYCLES];
            }
        }

        let mut neighbors =
            vec![vec![vec![Vec::with_capacity(0); dimensions[2]]; dimensions[1]]; dimensions[0]];
        for z in 0..dimensions[0] {
            for y in 0..dimensions[1] {
                for x in 0..dimensions[2] {
                    let coord = [z, y, x];
                    neighbors[z][y][x] = ThreeDimGrid::calc_neighbor_coords(&coord, &dimensions);
                }
            }
        }

        ThreeDimGrid {
            dimensions,
            active_range,
            state,
            neighbors,
        }
    }

    #[allow(dead_code)]
    pub fn pprint(&self) {
        let state = &self.state;
        for (i, z) in state.iter().enumerate() {
            println!("z = {}", i);
            for y in z {
                for x in y {
                    match x {
                        true => print!("#"),
                        false => print!("."),
                    }
                }
                println!("");
            }
            println!("\n");
        }
    }

    #[rustfmt::skip]
    pub fn calc_neighbor_coords(coord: &[usize; 3], dims: &[usize; 3]) -> Vec<[usize; 3]> {
        let zrange = 0..(dims[0] as isize);
        let yrange = 0..(dims[1] as isize);
        let xrange = 0..(dims[2] as isize);

        let mut neighbors = Vec::with_capacity(26);
        for z in -1..2 {
            let zcoord = z + coord[0] as isize;
            if !zrange.contains(&zcoord) { continue; }
            for y in -1..2 {
                let ycoord = y + coord[1] as isize;
                if !yrange.contains(&ycoord) { continue; }
                for x in -1..2 {
                    let xcoord = x + coord[2] as isize;
                    if !xrange.contains(&xcoord) { continue; }
                    if x == 0 && y == 0 && z == 0 { continue; }
                    neighbors.push([zcoord as usize, ycoord as usize, xcoord as usize]);
                }
            }
        }
        neighbors
    }

    fn get_active_neighbors(&self, state: &Vec<Vec<Vec<bool>>>, coord: &[usize; 3]) -> u8 {
        let coord_neighbors = &self.neighbors[coord[0]][coord[1]][coord[2]];

        let mut active_neighbors = 0;
        let in_slice_layer = coord[0] == CYCLES; // The z-layer the slice was inserted into
        for n in coord_neighbors {
            if state[n[0]][n[1]][n[2]] {
                // If the z coordinate is in the original slice layer, then we need to account
                // for the reflected layer underneath that we aren't calculating.
                if in_slice_layer && n[0] != coord[0] {
                    active_neighbors += 1;
                }
                active_neighbors += 1;
            }
        }

        active_neighbors
    }

    pub fn advance_state(&mut self) {
        let new_grid_state = self.state.clone();

        // Expand the active range by one in all directions to account for new active cubes
        let old_range = &self.active_range;
        self.active_range = [
            (old_range[0].0 - 1, old_range[0].1),
            (old_range[1].0 - 1, old_range[1].1 + 1),
            (old_range[2].0 - 1, old_range[2].1 + 1),
        ];

        for z in self.active_range[0].0..self.active_range[0].1 {
            for y in self.active_range[1].0..self.active_range[1].1 {
                for x in self.active_range[2].0..self.active_range[2].1 {
                    let active_neighbors = self.get_active_neighbors(&self.state, &[z, y, x]);
                    let new_cube_state = match self.state[z][y][x] {
                        true => active_neighbors == 2 || active_neighbors == 3,
                        false => active_neighbors == 3,
                    };
                    self.state[z][y][x] = new_cube_state;
                }
            }
        }

        self.state = new_grid_state;
    }

    pub fn advance_n_times(&mut self, n: u8) {
        for _ in 0..n {
            self.advance_state()
        }
    }

    pub fn count_active(&self) -> u32 {
        let mut active = 0;
        for z in 0..self.dimensions[0] {
            for y in 0..self.dimensions[1] {
                for x in 0..self.dimensions[2] {
                    // Only count cubes in the 'slice' layer once, counts cubes in the other
                    // layers twice, since they are mirrored.
                    if self.state[z][y][x] && z == CYCLES {
                        active += 1;
                    } else if self.state[z][y][x] {
                        active += 2
                    }
                }
            }
        }

        active
    }
}
