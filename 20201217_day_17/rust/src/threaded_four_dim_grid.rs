use crate::CYCLES;
use std::sync::mpsc::{Receiver, Sender};
use std::sync::{mpsc, Arc};
use std::thread;

pub struct ThreadedFourDimGrid {
    dimensions: [usize; 4],
    active_range: [(usize, usize); 4],
    state: Arc<Vec<Vec<Vec<Vec<bool>>>>>,
    neighbors: Arc<Vec<Vec<Vec<Vec<Vec<[usize; 4]>>>>>>,
}

impl ThreadedFourDimGrid {
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
                            ThreadedFourDimGrid::calc_neighbor_coords(&coord, &dimensions);
                    }
                }
            }
        }

        ThreadedFourDimGrid {
            dimensions,
            active_range,
            state: Arc::new(state),
            neighbors: Arc::new(neighbors),
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
                    active_neighbors += 1; // Reflection across both the q and z axes
                }
                if in_qslice && n[0] != coord[0] {
                    active_neighbors += 1; // Reflection across the central q axis
                }
                if in_zslice && n[1] != coord[1] {
                    active_neighbors += 1; // Reflection across the central z axis
                }
                active_neighbors += 1;
            }
        }

        active_neighbors
    }

    /// In order to use threading, this function needs to not rely on references to 'self'
    fn next_cube_state(
        state: &Vec<Vec<Vec<Vec<bool>>>>,
        neighbors: &Vec<[usize; 4]>,
        coord: &[usize; 4],
    ) -> bool {
        let mut active_neighbors = 0;
        // The q and z-layers the slice was inserted into
        let in_qslice = coord[0] == CYCLES;
        let in_zslice = coord[1] == CYCLES;
        let in_slice = in_qslice && in_zslice;
        for n in neighbors {
            if state[n[0]][n[1]][n[2]][n[3]] {
                if in_slice && n[0] != coord[0] && n[1] != coord[1] {
                    active_neighbors += 1; // Reflection across both the q and z axes
                }
                if in_qslice && n[0] != coord[0] {
                    active_neighbors += 1; // Reflection across the central q axis
                }
                if in_zslice && n[1] != coord[1] {
                    active_neighbors += 1; // Reflection across the central z axis
                }
                active_neighbors += 1;
            }
        }

        match state[coord[0]][coord[1]][coord[2]][coord[3]] {
            true => active_neighbors == 2 || active_neighbors == 3,
            false => active_neighbors == 3,
        }
    }

    pub fn advance_state(&mut self) {
        // Expand the active range by one in all directions to account for new active cubes
        let old_range = &self.active_range;
        let active_range = [
            (old_range[0].0 - 1, old_range[0].1),
            (old_range[1].0 - 1, old_range[1].1),
            (old_range[2].0 - 1, old_range[2].1 + 1),
            (old_range[3].0 - 1, old_range[3].1 + 1),
        ];

        let mut child_threads = Vec::new();
        let (tx, rx): (
            Sender<Vec<([usize; 4], bool)>>,
            Receiver<Vec<([usize; 4], bool)>>,
        ) = mpsc::channel();
        for q in active_range[0].0..active_range[0].1 {
            for z in active_range[1].0..active_range[1].1 {
                let thread_tx = tx.clone();
                let state = Arc::clone(&self.state);
                let neighbors = Arc::clone(&self.neighbors);
                let child = thread::spawn(move || {
                    let mut updates: Vec<([usize; 4], bool)> = Vec::new();

                    for y in active_range[2].0..active_range[2].1 {
                        for x in active_range[3].0..active_range[3].1 {
                            let new_cube_state = ThreadedFourDimGrid::next_cube_state(
                                &state,
                                &neighbors[q][z][y][x],
                                &[q, z, y, x],
                            );
                            // Only push updates when the state is to change
                            if &state[q][z][y][x] != &new_cube_state {
                                updates.push(([q, z, y, x], new_cube_state))
                            }
                        }
                    }

                    thread_tx.send(updates).unwrap(); // Send updates to the channel
                });
                child_threads.push(child);
            }
        }

        // Read all the updates from all the channels and update the state.
        let mut updates: Vec<([usize; 4], bool)> = Vec::with_capacity(2000);
        for _ in active_range[0].0..active_range[0].1 {
            for _ in active_range[1].0..active_range[1].1 {
                for update in rx.recv() {
                    updates.extend(update);
                }
            }
        }

        for child in child_threads {
            child.join().expect("oops! the child thread panicked");
        }

        let mut_self_state = Arc::get_mut(&mut self.state).unwrap();
        for u in updates {
            mut_self_state[u.0[0]][u.0[1]][u.0[2]][u.0[3]] = u.1;
        }

        self.active_range = active_range;
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
