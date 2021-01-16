use crate::CYCLES;
use std::sync::mpsc::{Receiver, Sender};
use std::sync::{mpsc, Arc};
use std::thread;

pub struct ThreeDimGrid {
    dimensions: [usize; 3],
    active_range: [(usize, usize); 3],
    state: Arc<Vec<Vec<Vec<bool>>>>,
    neighbors: Arc<Vec<Vec<Vec<Vec<[usize; 3]>>>>>,
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
            state: Arc::new(state),
            neighbors: Arc::new(neighbors),
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

    /// In order to use threading, this function needs to not rely on references to 'self'
    fn next_cube_state(
        state: &Vec<Vec<Vec<bool>>>,
        neighbors: &Vec<[usize; 3]>,
        coord: &[usize; 3],
    ) -> bool {
        let mut active_neighbors = 0;
        let in_slice = coord[0] == CYCLES;
        for n in neighbors {
            if state[n[0]][n[1]][n[2]] {
                if in_slice && n[0] != coord[0] {
                    active_neighbors += 1
                }
                active_neighbors += 1
            }
        }

        match state[coord[0]][coord[1]][coord[2]] {
            true => active_neighbors == 2 || active_neighbors == 3,
            false => active_neighbors == 3,
        }
    }

    pub fn advance_state(&mut self) {
        // Expand the active range by one in all directions to account for new active cubes
        let old_range = &self.active_range;
        let active_range = [
            (old_range[0].0 - 1, old_range[0].1),
            (old_range[1].0 - 1, old_range[1].1 + 1),
            (old_range[2].0 - 1, old_range[2].1 + 1),
        ];

        // Threaded code. Spawns a thread for each z-layer, and sends all the updates for that
        // layer to a channel.
        let mut child_threads = Vec::new();
        let (tx, rx): (
            Sender<Vec<([usize; 3], bool)>>,
            Receiver<Vec<([usize; 3], bool)>>,
        ) = mpsc::channel();
        for z in active_range[0].0..active_range[0].1 {
            let thread_tx = tx.clone();
            let state = Arc::clone(&self.state);
            let neighbors = Arc::clone(&self.neighbors);
            let child = thread::spawn(move || {
                let mut updates: Vec<([usize; 3], bool)> = Vec::new();

                for y in active_range[1].0..active_range[1].1 {
                    for x in active_range[2].0..active_range[2].1 {
                        let new_cube_state =
                            ThreeDimGrid::next_cube_state(&state, &neighbors[z][y][x], &[z, y, x]);

                        // Only push updates when the state is to change
                        if &state[z][y][x] != &new_cube_state {
                            updates.push(([z, y, x], new_cube_state))
                        }
                    }
                }

                thread_tx.send(updates).unwrap(); // Send updates to the channel
            });
            child_threads.push(child);
        }

        // Read all the updates from all the channels and update the state.
        let mut updates: Vec<([usize; 3], bool)> = Vec::with_capacity(2000);
        for _ in active_range[0].0..active_range[0].1 {
            for update in rx.recv() {
                updates.extend(update);
            }
        }

        for child in child_threads {
            child.join().expect("oops! the child thread panicked");
        }

        let mut_self_state = Arc::get_mut(&mut self.state).unwrap();
        for u in updates {
            mut_self_state[u.0[0]][u.0[1]][u.0[2]] = u.1;
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
