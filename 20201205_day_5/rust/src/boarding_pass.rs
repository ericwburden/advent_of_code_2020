use std::ops::Range;

// Struct to represent a boarding pass, contains field for the row indicators and seat indicators
#[derive(Debug)]
pub struct BoardingPass {
    row_array: [char; 7],
    seat_array: [char; 3],
}

// Methods for a boarding pass struct
impl BoardingPass {
    // Parses a line from the input file into a BoardingPass
    pub fn from_string(pass_str: &str) -> BoardingPass {
        let mut row_array = ['X'; 7];
        for (i, c) in pass_str[..7].chars().enumerate() {
            row_array[i] = c;
        }

        let mut seat_array = ['X'; 3];
        for (i, c) in pass_str[7..10].chars().enumerate() {
            seat_array[i] = c;
        }

        BoardingPass{row_array, seat_array}
    }

    // Calculates a seat number for a BoardingPass
    pub fn seat_number(&self) -> u32 {
        let mut row_range: Range<u32> = 0..127;  // The available range of rows
        let mut seat_range: Range<u32> = 0..7;   // The available range of seats

        // For each element of the BoardingPass.row_array, divide the available rows in half based
        // on the puzzle directions ('F' for lower half, 'B' for upper half). Once it's narrowed
        // down to the end, there should be only one row left.
        for c in self.row_array.iter() {
            let halfway = ((row_range.end - row_range.start)/2) + row_range.start;
            row_range = match c {
                'B' => (halfway+1)..row_range.end,
                'F' => row_range.start..halfway,
                _ => panic!("{} not a valid row indicator", c),
            }
        }
        if row_range.start != row_range.end {
            panic!("Failed to find row from {:?}", self.row_array);
        }

        // For each element of the BoardingPass.seat_array, divide the available seats in half 
        // based on the puzzle directions ('L' for lower half, 'R' for upper half). Once it's 
        // narrowed down to the end, there should be only one seat left.
        for c in self.seat_array.iter() {
            let halfway = ((seat_range.end - seat_range.start)/2) + seat_range.start;
            seat_range = match c {
                'R' => (halfway+1)..seat_range.end,
                'L' => seat_range.start..halfway,
                _ => panic!("{} not a valid seat indicator", c),
            }
        }
        if seat_range.start != seat_range.end {
            panic!("Failed to find seat from {:?}", self.seat_array);
        }

        (row_range.start * 8) + seat_range.start  // Calculate and return seat number
    }
}