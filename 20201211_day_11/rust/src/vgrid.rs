use std::convert::TryFrom;
use std::fs::File;
use std::io::{BufRead, BufReader, Error};


/// Provides the possible directions to search for seats/spaces
#[rustfmt::skip]
pub enum Dir {
    West, NorthWest, North, NorthEast,
    East, SouthEast, South, SouthWest,
}

/// The array allows us to iterate through directions
#[rustfmt::skip]
const DIRECTIONS: [Dir; 8] = [
    Dir::West, Dir::NorthWest, Dir::North, Dir::NorthEast,
    Dir::East, Dir::SouthEast, Dir::South, Dir::SouthWest
];

/// The state of any given space in the grid
#[derive(Debug, PartialEq, Clone, Copy)]
enum State {
    Floor,
    Empty,
    Occupied,
}

/// The type of search strategy to implement when searching for neighbors in the grid
#[derive(Debug, PartialEq, Clone, Copy)]
pub enum NeighborSearchStrategy {
    AdjacentSpace,
    NearestSeat,
}

pub type Coord = (usize, usize);  // Justa shorthand for coordinates

/// Container struct for the seating area grid
#[derive(Debug)]
pub struct VecGrid {
    width: usize,
    height: usize,
    spaces: Vec<Vec<State>>,
    search_strategy: NeighborSearchStrategy,
}

impl VecGrid {
    /// Pretty prints the grid
    #[allow(dead_code)]
    pub fn pprint(&self) {
        let grid = &self.spaces;
        for row in grid {
            println!("");
            for c in row {
                match c {
                    &State::Floor => print!("."),
                    &State::Empty => print!("L"),
                    &State::Occupied => print!("#"),
                }
            }
        }
        println!("")
    }

    /// Reads the character grid from a file and parses into a VecGrid. Also takes a search
    /// strategy that will set how neighbors are determined for advancing from one state to the 
    /// next
    pub fn from_file(
        filename: &str,
        search_strategy: NeighborSearchStrategy,
    ) -> Result<Self, Error> {
        let file = File::open(&filename)?; // Open file or panic
        let br = BufReader::new(file); // Create read buffer
        let mut spaces = Vec::new(); // Initialize empty vector
        let mut width = 0;
        let mut height = 0;

        // For each line in the input file...
        for line in br.lines() {
            let line_string = line?.trim().to_string();
            height += 1;
            width = line_string.len();
            let mut row_vec = Vec::with_capacity(width);
            for c in line_string.chars() {
                let state = match c {
                    'L' => State::Empty,
                    '#' => State::Occupied,
                    '.' => State::Floor,
                    _ => panic!("Cannot parse input."),
                };
                row_vec.push(state);
            }
            spaces.push(row_vec);
        }

        let vec_grid = VecGrid {
            width,
            height,
            spaces,
            search_strategy,
        };

        return Ok(vec_grid); // Return data
    }

    /// Given a coordinate and a direction, optionally return the coordinate of the space you land
    /// on if you start at coordinate and move one space in the given direction. Optional to 
    /// provide safety against checking coordinates outside the grid.
    #[rustfmt::skip]
    fn adjacent_space(&self, coord: &Coord, dir: &Dir) -> Option<Coord> {
        let mut row = coord.0 as isize;
        let mut col = coord.1 as isize;

        match dir {
            &Dir::West => { col -= 1 },
            &Dir::NorthWest => { row -= 1; col -= 1 },
            &Dir::North => { row -= 1 },
            &Dir::NorthEast => { row -= 1; col += 1 },
            &Dir::East => { col += 1 },
            &Dir::SouthEast => { row += 1; col += 1 },
            &Dir::South => { row += 1 },
            &Dir::SouthWest => { row += 1; col -= 1 },
        };

        let row = usize::try_from(row).ok()?;
        let col = usize::try_from(col).ok()?;
        
        if row < self.height && col < self.width {
            Some((row, col))
        } else {
            None
        }
    }

    /// Given a coordinate and a direction, optionally return the state of the grid space you land
    /// on moving one space from coordinate in the given direction.
    fn get_adjacent_space_state(&self, coord: &Coord, dir: &Dir) -> Option<State> {
        let spaces = &self.spaces;
        let adj_space_coord = self.adjacent_space(coord, dir)?;
        let row = adj_space_coord.0;
        let col = adj_space_coord.1;
        Some(*spaces.get(row)?.get(col)?)
    }

    /// Given a coordinate and a direction, optionally return the state of the first seat
    /// encountered by moving in the given direction. Floor spaces are ignored.
    fn get_nearest_seat_state(&self, coord: &Coord, dir: &Dir) -> Option<State> {
        let mut check_coord = *coord;
        while let Some(c) = self.adjacent_space(&check_coord, dir) {
            let state = self.spaces.get(c.0)?.get(c.1)?;
            match state {
                &State::Empty | &State::Occupied => return Some(*state),
                &State::Floor => check_coord = c,
            }
        }
        None
    }

    /// Given a coordinate, optionally return the state the space would take after taking 
    /// neighboring spaced into account.
    fn next_space_state(&self, coord: &Coord) -> Option<State> {
        let state = *self.spaces.get(coord.0)?.get(coord.1)?;
        if let State::Floor = state {
            return Some(State::Floor);
        };
        let abandon_seat_threshold = match self.search_strategy {
            NeighborSearchStrategy::AdjacentSpace => 4,
            NeighborSearchStrategy::NearestSeat => 5,
        };
        let mut occupied = 0;

        for dir in DIRECTIONS.iter() {
            let maybe_dir_state = match self.search_strategy {
                NeighborSearchStrategy::AdjacentSpace => self.get_adjacent_space_state(coord, dir),
                NeighborSearchStrategy::NearestSeat => self.get_nearest_seat_state(coord, dir),
            };
            if let Some(s) = maybe_dir_state {
                if s == State::Occupied {
                    occupied += 1
                }
            };
            match state {
                State::Empty => {
                    if occupied > 0 {
                        return Some(State::Empty);
                    }
                }
                State::Occupied => {
                    if occupied >= abandon_seat_threshold {
                        return Some(State::Empty);
                    }
                }
                State::Floor => continue,
            }
        }

        Some(State::Occupied)
    }
    
    /// Iterate over all grid spaces and optionally return a new VecGrid containing the next
    /// board state. Returns None if the grid state would not change.
    pub fn next_state(&self) -> Option<Self> {
        let spaces = &self.spaces;
        let mut new_spaces = Vec::with_capacity(self.height);

        for (row_idx, row) in spaces.iter().enumerate() {
            let mut new_row = Vec::with_capacity(self.width);

            for (col_idx, _) in row.iter().enumerate() {
                let coord = (row_idx, col_idx);
                let new_space = self.next_space_state(&coord)?;
                new_row.push(new_space);
            }

            new_spaces.push(new_row);
        }

        if spaces == &new_spaces {
            return None;
        }

        let width = self.width;
        let height = self.height;
        let search_strategy = self.search_strategy;
        let new_grid = VecGrid {
            width,
            height,
            spaces: new_spaces,
            search_strategy,
        };
        Some(new_grid)
    }

    /// Count the number of occupied seats and return the count
    pub fn occupied_seats(&self) -> usize {
        let mut occupied = 0;
        for row in &self.spaces {
            for space in row {
                if let State::Occupied = space {
                    occupied += 1;
                }
            }
        }
        occupied
    }
}
