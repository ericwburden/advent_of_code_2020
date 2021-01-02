// --- Day 1: Report Repair ---
//
// After saving Christmas five years in a row, you've decided to take a
// vacation at a nice resort on a tropical island. Surely, Christmas will go on
// without you.
//
// The tropical island has its own currency and is entirely cash-only. The gold
// coins used there have a little picture of a starfish; the locals just call
// them stars. None of the currency exchanges seem to have heard of them, but
// somehow, you'll need to find fifty of these coins by the time you arrive so
// you can pay the deposit on your room.
//
// To save your vacation, you need to get all fifty stars by December 25th.
//
// Collect stars by solving puzzles. Two puzzles will be made available on
// each day in the Advent calendar; the second puzzle is unlocked when you
// complete the first. Each puzzle grants one star. Good luck!
//
// Before you leave, the Elves in accounting just need you to fix your expense
// report (your puzzle input); apparently, something isn't quite adding up.
//
// Specifically, they need you to find the two entries that sum to 2020 and
// then multiply those two numbers together.
//
// For example, suppose your expense report contained the following:
// > 1721
// > 979
// > 366
// > 299
// > 675
// > 1456
//
// In this list, the two entries that sum to 2020 are 1721 and 299. Multiplying
// them together produces 1721 * 299 = 514579, so the correct answer is 514579.
//
// Of course, your expense report is much larger. Find the two entries that sum
// to 2020; what do you get if you multiply them together?

use std::cmp::Ordering;
use std::fs::File;
use std::io::{BufRead, BufReader, Error, ErrorKind};
use std::time::Instant;

// Function to read in lines from an input file and convert them to a Vec<i32>
fn read_input(filename: &str) -> Result<Vec<i32>, Error> {
    let file = File::open(&filename)?; // Open file or panic
    let br = BufReader::new(file); // Create read buffer
    let mut v = vec![]; // Initialize empty vector

    // For each line in the buffered reader, read the contents to an i32 and
    // push to `v`. Panic if no line is found.
    for line in br.lines() {
        v.push(
            line?
                .trim()
                .parse()
                .map_err(|e| Error::new(ErrorKind::InvalidData, e))?,
        );
    }

    return Ok(v); // Return data
}

fn part_one(data: &mut Vec<i32>, target_num: i32) {
    data.sort_unstable(); // Sort the input Vec ascending

    // Pointers along `input_data`
    let mut p1 = 0;
    let mut p2 = &data.len() - 1;

    // So long as the pointers don't cross, check the numbers indicated by the
    // pointers. If their sum is less than `target_num` move p1 forward, if
    // their sum is greater than `target_num`, move p2 backward.
    while p1 < p2 {
        let current_total = &data[p1] + &data[p2];
        match target_num.cmp(&current_total) {
            Ordering::Greater => p1 = p1 + 1,
            Ordering::Less => p2 = p2 - 1,
            Ordering::Equal => break,
        }
    }

    // Share the answers we found!
    let answer1 = &data[p1] * &data[p2];
    println!("The answer to part 1 is {}", answer1);

    // Answer: 55776
}

// --- Part Two ---
//
// The Elves in accounting are thankful for your help; one of them even offers
// you a starfish coin they had left over from a past vacation. They offer you
// a second one if you can find three numbers in your expense report that meet
// the same criteria.
//
// Using the above example again, the three entries that sum to 2020 are 979,
// 366, and 675. Multiplying them together produces the answer, 241861950.
//
// In your expense report, what is the product of the three entries that sum
// to 2020?

fn part_two_cascading(data: &mut Vec<i32>, target_num: i32) {
    // Sort the input data. Needs to be in descending order to optimize the
    // search loop. This way, if the sum of the numbers we're pointing to with
    // our pointers is ever less than `target_num`, we know we won't find the
    // answer by moving the current pointer forward.
    data.sort_unstable();
    data.reverse();

    // Three pointers to find three numbers, the first moving pointer `mp` is
    // the last array index.
    let mut pointers = [0, 1, 2];
    let mut mp = 2;

    // So long as the first pointer hasn't moved as far forward as it can...
    while pointers[0] < data.len() - 3 {
        // Identify the farthest index the moving pointer `mp` can reach,
        // accounting for `input_data` length and the other pointers.
        // No two pointers should ever point to the same index.
        let farthest_point = data.len() - (pointers.len() - mp);
        // The sum of the three numbers currently indicated by the pointers
        let current_total = pointers
            .iter()
            .map(|x| data[*x])
            .fold(0, |total, next| total + next);

        // Success!
        if current_total == target_num {
            break;
        }

        // If the currently moving pointer has moved down `input_data` as far
        // as it can go (or we know we won't find the answer moving it
        // forward because `current_total` is less than `target_num`), change
        // the moving pointer to the preceding pointer. If we're already on the
        // first pointer, then we know we're done and we haven't found the
        // answer.
        if pointers[mp] == farthest_point || current_total < target_num {
            if mp == 0 {
                panic!("Couldn't find the answer to part 2.");
            }
            mp = mp - 1;
        }

        pointers[mp] = pointers[mp] + 1; // Move the current pointer forward

        // If we're not moving the last pointer in the array, we need to see
        // how far the moving pointer `mp` is from the pointer just after it in
        // the array. If there's space between them, set that next pointer as the
        // moving pointer and point it at the index just after the pointer that
        // was previously moving
        if mp < (pointers.len() - 1) {
            let distance_to_next_pointer = pointers[mp + 1] - pointers[mp];
            if distance_to_next_pointer > 1 {
                let last_point = pointers[mp];
                mp = mp + 1;
                pointers[mp] = last_point + 1;
            }
        }
    }

    let answer2 = pointers
        .iter()
        .map(|x| data[*x])
        .fold(1, |total, next| total * next);

    println!("The answer to part 2 (pointer cascade) is {}", answer2);
    // Answer: 223162626
}

fn part_two_diff(data: &mut Vec<i32>, target_num: i32) {
    // The data needs to be sorted ascending, just like for part one, since
    // this approach is very similar
    data.sort_unstable();

    // Prepare a Vec<i32> of the values from `data` subtracted from `target_num`
    let mut diffs = Vec::with_capacity(data.len());
    for n in data.iter() {
        diffs.push(target_num - n);
    }

    // Initialize `answer` as a None. If it's still None at the end, then we
    // couldn't find the answer
    let mut answer: Option<i32> = None;
    for (i, &diff) in diffs.iter().enumerate() {
        // Start with a pointer at the 'beginning' of `data`, and another at the
        // end. `p1` can start at index `i` because it will have already tested
        // the combinations where `p1` is less than `i`
        let mut p1 = i;
        let mut p2 = data.len() - 1;

        // So long as the pointers don't cross, check the numbers indicated by the
        // pointers. If their sum is less than `target_num` move p1 forward, if
        // their sum is greater than `target_num`, move p2 backward.
        while p1 < p2 {
            let current_total = data[p1] + data[p2];
            match &diff.cmp(&current_total) {
                Ordering::Greater => p1 = p1 + 1,
                Ordering::Less => p2 = p2 - 1,
                Ordering::Equal => break,
            }
        }

        // If we've found the three numbers that sum to `target_num`, then
        // set the answer to a Some containing those three numbers multiplied
        // together
        if data[i] + data[p1] + data[p2] == target_num {
            answer = Some(data[i] * data[p1] * data[p2]);
            break;
        }
    }

    // Share the answers we found!
    match answer {
        Some(x) => println!("The answer to part 2 (diff pointers) is {}.", x),
        None => println!("Couldn't find answer to part 2."),
    }
    // Answer: 223162626
}

// Timing function, given the function to run and the input arguments, runs
// the function with the given input and prints the time to run to the
// console
fn time_it(f: fn(&mut Vec<i32>, i32) -> (), data: &mut Vec<i32>, target_num: i32) {
    let start = Instant::now();
    f(data, target_num);
    let duration = start.elapsed();

    println!("Solved in: {:?}\n\n", duration);
}

fn main() {
    // Read in input data
    let mut input_data = match read_input("../input.txt") {
        Ok(data) => data,
        Err(_) => panic!("Could not read input file."),
    };

    let target_num = 2020;

    // Run the three functions with timing!
    time_it(part_one, &mut input_data, target_num);
    time_it(part_two_cascading, &mut input_data, target_num);
    time_it(part_two_diff, &mut input_data, target_num);
}
