// --- Day 5: Binary Boarding ---
// 
// You board your plane only to discover a new problem: you dropped your boarding pass! You aren't 
// sure which seat is yours, and all of the flight attendants are busy with the flood of people 
// that suddenly made it through passport control.
// 
// You write a quick program to use your phone's camera to scan all of the nearby boarding passes 
// (your puzzle input); perhaps you can find your seat through process of elimination.
// 
// Instead of zones or groups, this airline uses binary space partitioning to seat people. A seat 
// might be specified like FBFBBFFRLR, where F means "front", B means "back", L means "left", and 
// R means "right".
// 
// The first 7 characters will either be F or B; these specify exactly one of the 128 rows on the 
// plane (numbered 0 through 127). Each letter tells you which half of a region the given seat is 
// in. Start with the whole list of rows; the first letter indicates whether the seat is in the 
// front (0 through 63) or the back (64 through 127). The next letter indicates which half of that 
// region the seat is in, and so on until you're left with exactly one row.
// 
// For example, consider just the first seven characters of FBFBBFFRLR:
// 
//     Start by considering the whole range, rows 0 through 127.
//     F means to take the lower half, keeping rows 0 through 63.
//     B means to take the upper half, keeping rows 32 through 63.
//     F means to take the lower half, keeping rows 32 through 47.
//     B means to take the upper half, keeping rows 40 through 47.
//     B keeps rows 44 through 47.
//     F keeps rows 44 through 45.
//     The final F keeps the lower of the two, row 44.
// 
// The last three characters will be either L or R; these specify exactly one of the 8 columns of 
// seats on the plane (numbered 0 through 7). The same process as above proceeds again, this time 
// with only three steps. L means to keep the lower half, while R means to keep the upper half.
// 
// For example, consider just the last 3 characters of FBFBBFFRLR:
// 
//     Start by considering the whole range, columns 0 through 7.
//     R means to take the upper half, keeping columns 4 through 7.
//     L means to take the lower half, keeping columns 4 through 5.
//     The final R keeps the upper of the two, column 5.
// 
// So, decoding FBFBBFFRLR reveals that it is the seat at row 44, column 5.
// 
// Every seat also has a unique seat ID: multiply the row by 8, then add the column. In this 
// example, the seat has ID 44 * 8 + 5 = 357.
// 
// Here are some other boarding passes:
// 
//     BFFFBBFRRR: row 70, column 7, seat ID 567.
//     FFFBBBFRRR: row 14, column 7, seat ID 119.
//     BBFFBBFRLL: row 102, column 4, seat ID 820.
// 
// As a sanity check, look through your list of boarding passes. What is the highest seat ID on a 
// boarding pass?
// 
// Your puzzle answer was 818.

// --- Part Two ---
// 
// Ding! The "fasten seat belt" signs have turned on. Time to find your seat.
// 
// It's a completely full flight, so your seat should be the only missing boarding pass in your 
// list. However, there's a catch: some of the seats at the very front and back of the plane don't 
// exist on this aircraft, so they'll be missing from your list as well.
// 
// Your seat wasn't at the very front or back, though; the seats with IDs +1 and -1 from yours 
// will be in your list.
// 
// What is the ID of your seat?
// 
// Your puzzle answer was 559.

mod fileio;
mod boarding_pass;

use boarding_pass::BoardingPass;
use std::time::Instant;

// Part One, find the highest seat number in the Vec of seat numbers
fn part_one(seat_numbers: &Vec<u32>) {
    let max_seat_number = seat_numbers.iter()
        .fold(0, |max, next| if next > &max { *next } else { max });
        
    println!("\nLargest seat number: {}, part one.", max_seat_number);
}

// Part Two, find the missing seat number in the Vec of seat numbers.
fn part_two(seat_numbers: &Vec<u32>) {
    let mut missing_seat_number = 0;
    for (i, n) in seat_numbers.iter().enumerate() {
        if i == 0 || i == seat_numbers.len() - 1 { continue; }

        // If the next seat number is missing, that's the missing seat number
        if n+1 != seat_numbers[i+1] {
            missing_seat_number = *n + 1;
            break;
        }
    }

    println!("\nMissing seat number: {}, part two", missing_seat_number);
}

// Timing function, given the function to run and the input arguments, runs
// the function with the given input and prints the time to run to the
// console
fn time_it(f: fn(&Vec<u32>) -> (), seat_numbers: &Vec<u32>) {
    let start = Instant::now();
    f(&seat_numbers);
    let duration = start.elapsed();

    println!("Solved in: {:?}\n", duration);
}

fn main() {
       // Read in the input file to Vec<String>
    let input_lines = match fileio::read_input("../input.txt") {
        Ok(x) => x,
        Err(_) => panic!("Couldn't parse input.")
    };

    // Parse boarding passes into structured data
    let mut boarding_passes = Vec::new();
    for line in input_lines {
        boarding_passes.push(BoardingPass::from_string(&line));
    }

    // Get the seat number for each boarding pass
    let mut seat_numbers: Vec<u32> = boarding_passes.iter()
        .map(|x| x.seat_number())
        .collect();
    
    seat_numbers.sort_unstable();  // Sort seat numbers, for part two

    time_it(part_one, &seat_numbers); // 818
    time_it(part_two, &seat_numbers); // 559
    
}
