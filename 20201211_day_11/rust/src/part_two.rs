use crate::vgrid::{NeighborSearchStrategy, VecGrid};

pub fn solve(filename: &str) {
    //! Using the NearestSeat search strategy, repeatedly get the next state of the VecGrid until
    //! the call to `next_state()` returns None, indicating the grid has reached a steady state.
    let search_strategy = NeighborSearchStrategy::NearestSeat;
    let mut vec_grid = VecGrid::from_file(filename, search_strategy).ok().unwrap();
    let final_grid = loop {
        // vec_grid.pprint();
        let maybe_new_grid = vec_grid.next_state();
        match maybe_new_grid {
            Some(vg) => vec_grid = vg,
            None => break vec_grid,
        }
    };
    // final_grid.pprint();
    let answer = final_grid.occupied_seats();
    println!("\nFound {} occupied seats, part two", answer);
}
