use crate::CYCLES;

pub struct FourDimGrid {
    dimensions: [usize; 4],
    active_range: [(usize, usize); 4],
    state: Vec<Vec<Vec<Vec<bool>>>>,
    neighbors: Vec<Vec<Vec<Vec<Vec<[usize; 4]>>>>>,
}

impl FourDimGrid {
    pub fn from_slice(slice: &Vec<Vec<bool>>) -> Self {
        let slice_dims = [1, 1, slice[0].len(), slice.len()];
        let dimensions = [
            slice_dims[0] + CYCLES,
            slice_dims[1] + CYCLES,
            slice_dims[2] + (CYCLES * 2),
            slice_dims[3] + (CYCLES * 2),
        ];

        // The active range is the region larger than the slice by one increment in every
        // dimension. It contains all the cubes that might become active in the next advancement.
        let active_range = [
            (CYCLES, CYCLES + slice_dims[0]),
            (CYCLES, CYCLES + slice_dims[1]),
            (CYCLES, CYCLES + slice_dims[2]),
            (CYCLES, CYCLES + slice_dims[3]),
        ];

        let mut state = vec![
            vec![vec![vec![false; dimensions[3]]; dimensions[2]]; dimensions[1]];
            dimensions[0]
        ];
        for y in (CYCLES)..(CYCLES + slice_dims[2]) {
            for x in (CYCLES)..(CYCLES + slice_dims[3]) {
                state[CYCLES][CYCLES][y][x] = slice[y - CYCLES][x - CYCLES];
            }
        }

        let mut neighbors = vec![
            vec![
                vec![vec![Vec::with_capacity(1); dimensions[3]]; dimensions[2]];
                dimensions[1]
            ];
            dimensions[0]
        ];
        for q in 0..dimensions[0] {
            for z in 0..dimensions[1] {
                for y in 0..dimensions[2] {
                    for x in 0..dimensions[3] {
                        let coord = [q, z, y, x];
                        neighbors[q][z][y][x] =
                            FourDimGrid::calc_neighbor_coords(&coord, &dimensions);
                    }
                }
            }
        }

        FourDimGrid {
            dimensions,
            active_range,
            state,
            neighbors,
        }
    }

    #[allow(dead_code)]
    pub fn pprint(&self) {
        for (j, q) in self.state.iter().enumerate() {
            for (i, z) in q.iter().enumerate() {
                println!("q = {}; z = {}", j, i);
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
    }

    #[rustfmt::skip]
    pub fn calc_neighbor_coords(coord: &[usize; 4], dims: &[usize; 4]) -> Vec<[usize; 4]> {
        let qrange = 0..(dims[0] as isize);
        let zrange = 0..(dims[1] as isize);
        let yrange = 0..(dims[2] as isize);
        let xrange = 0..(dims[3] as isize);

        let mut neighbors = Vec::with_capacity(80);
        for q in -1..2 {
            let qcoord = q + coord[0] as isize;
            if !qrange.contains(&qcoord) { continue; }
            for z in -1..2 {
                let zcoord = z + coord[1] as isize;
                if !zrange.contains(&zcoord) { continue; }
                for y in -1..2 {
                    let ycoord = y + coord[2] as isize;
                    if !yrange.contains(&ycoord) { continue; }
                    for x in -1..2 {
                        let xcoord = x + coord[3] as isize;
                        if !xrange.contains(&xcoord) { continue; }
                        if x == 0 && y == 0 && z == 0 && q == 0 { continue; }
                        neighbors.push([qcoord as usize, zcoord as usize, ycoord as usize, xcoord as usize]);
                    }
                }
            }
        }
        neighbors
    }

    pub fn get_active_neighbors(&self, coord: &[usize; 4]) -> u8 {
        let coord_neighbors = &self.neighbors[coord[0]][coord[1]][coord[2]][coord[3]];

        let mut active_neighbors = 0;
        // The q and z-layers the slice was inserted into
        let in_qslice = coord[0] == CYCLES;
        let in_zslice = coord[1] == CYCLES;
        let in_slice = in_qslice && in_zslice;
        for n in coord_neighbors {
            if self.state[n[0]][n[1]][n[2]][n[3]] {
                if in_slice && n[0] != coord[0] && n[1] != coord[1] {
                    active_neighbors += 1;
                }
                if in_qslice && n[0] != coord[0] {
                    active_neighbors += 1;
                }
                if in_zslice && n[1] != coord[1] {
                    active_neighbors += 1;
                }
                active_neighbors += 1;
            }
        }

        active_neighbors
    }

    pub fn advance_state(&mut self) {
        let mut new_grid_state = self.state.clone();

        // Expand the active range by one in all directions to account for new active cubes
        let old_range = &self.active_range;
        self.active_range = [
            (old_range[0].0 - 1, old_range[0].1),
            (old_range[1].0 - 1, old_range[1].1),
            (old_range[2].0 - 1, old_range[2].1 + 1),
            (old_range[3].0 - 1, old_range[3].1 + 1),
        ];

        let qrange = self.active_range[0].0..self.active_range[0].1;
        let zrange = self.active_range[1].0..self.active_range[1].1;
        let yrange = self.active_range[2].0..self.active_range[2].1;
        let xrange = self.active_range[3].0..self.active_range[3].1;

        for q in qrange {
            for z in zrange.clone() {
                for y in yrange.clone() {
                    for x in xrange.clone() {
                        let active_neighbors = self.get_active_neighbors(&[q, z, y, x]);
                        let new_cube_state = match self.state[q][z][y][x] {
                            true => active_neighbors == 2 || active_neighbors == 3,
                            false => active_neighbors == 3,
                        };
                        new_grid_state[q][z][y][x] = new_cube_state;
                    }
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
        for q in 0..self.dimensions[0] {
            for z in 0..self.dimensions[1] {
                for y in 0..self.dimensions[2] {
                    for x in 0..self.dimensions[3] {
                        // Only count cubes in the 'slice' layer once, counts cubes in the other
                        // layers twice, since they are mirrored.
                        if self.state[q][z][y][x] && z == CYCLES && q == CYCLES {
                            active += 1;
                        } else if self.state[q][z][y][x] && z == CYCLES {
                            active += 2;
                        } else if self.state[q][z][y][x] && q == CYCLES {
                            active += 2;
                        } else if self.state[q][z][y][x] {
                            active += 4
                        }
                    }
                }
            }
        }

        active
    }
}
