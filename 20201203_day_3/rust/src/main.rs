// --- Day 3: Toboggan Trajectory ---
// 
// With the toboggan login problems resolved, you set off toward the airport. 
// While travel by toboggan might be easy, it's certainly not safe: there's 
// very minimal steering and the area is covered in trees. You'll need to see 
// which angles will take you near the fewest trees.
// 
// Due to the local geology, trees in this area only grow on exact integer 
// coordinates in a grid. You make a map (your puzzle input) of the open 
// squares (.) and trees (#) you can see. For example:
// 
// ..##.......
// #...#...#..
// .#....#..#.
// ..#.#...#.#
// .#...##..#.
// ..#.##.....
// .#.#.#....#
// .#........#
// #.##...#...
// #...##....#
// .#..#...#.#
// 
// These aren't the only trees, though; due to something you read about once 
// involving arboreal genetics and biome stability, the same pattern repeats 
// to the right many times:
// 
// ..##.........##.........##.........##.........##.........##.......  --->
// #...#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
// .#....#..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
// ..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
// .#...##..#..#...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
// ..#.##.......#.##.......#.##.......#.##.......#.##.......#.##.....  --->
// .#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
// .#........#.#........#.#........#.#........#.#........#.#........#
// #.##...#...#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...
// #...##....##...##....##...##....##...##....##...##....##...##....#
// .#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#  --->
// 
// You start on the open square (.) in the top-left corner and need to reach 
// the bottom (below the bottom-most row on your map).
// 
// The toboggan can only follow a few specific slopes (you opted for a cheaper 
// model that prefers rational numbers); start by counting all the trees you 
// would encounter for the slope right 3, down 1:
// 
// From your starting position at the top-left, check the position that is 
// right 3 and down 1. Then, check the position that is right 3 and down 1 
// from there, and so on until you go past the bottom of the map.
// 
// The locations you'd check in the above example are marked here with O where 
// there was an open square and X where there was a tree:
// 
// ..##.........##.........##.........##.........##.........##.......  --->
// #..O#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
// .#....X..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
// ..#.#...#O#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
// .#...##..#..X...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
// ..#.##.......#.X#.......#.##.......#.##.......#.##.......#.##.....  --->
// .#.#.#....#.#.#.#.O..#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
// .#........#.#........X.#........#.#........#.#........#.#........#
// #.##...#...#.##...#...#.X#...#...#.##...#...#.##...#...#.##...#...
// #...##....##...##....##...#X....##...##....##...##....##...##....#
// .#..#...#.#.#..#...#.#.#..#...X.#.#..#...#.#.#..#...#.#.#..#...#.#  --->
// 
// In this example, traversing the map using this slope would cause you to 
// encounter 7 trees.
// 
// Starting at the top-left corner of your map and following a slope of right 
// 3 and down 1, how many trees would you encounter?
// 
// Your puzzle answer was 232.

// --- Part Two ---
// 
// Time to check the rest of the slopes - you need to minimize the probability 
// of a sudden arboreal stop, after all.
// 
// Determine the number of trees you would encounter if, for each of the 
// following slopes, you start at the top-left corner and traverse the map all 
// the way to the bottom:
// 
//     Right 1, down 1.
//     Right 3, down 1. (This is the slope you already checked.)
//     Right 5, down 1.
//     Right 7, down 1.
//     Right 1, down 2.
// 
// In the above example, these slopes would find 2, 7, 3, 4, and 2 tree(s) 
// respectively; multiplied together, these produce the answer 336.
// 
// What do you get if you multiply together the number of trees encountered on 
// each of the listed slopes?
// 
// Your puzzle answer was 3952291680.

use std::fs::File;
use std::io::{BufRead, BufReader, Error};
use std::time::Instant;

// Function to read in lines from an input file and convert them to a Vec<String>
fn read_input(filename: &str) -> Result<Vec<String>, Error> {
    let file = File::open(&filename)?; // Open file or panic
    let br = BufReader::new(file); // Create read buffer
    let mut v = vec![]; // Initialize empty vector

    // For each line in the buffered reader, read the contents to an i32 and
    // push to `v`. Panic if no line is found.
    for line in br.lines() {
        v.push(line?.trim().to_string());
    }

    return Ok(v); // Return data
}

// Parse the characters from the input into a 2D Vec representing the
// map of the ski slope
fn parse_input(input_lines: &Vec<String>) -> Vec<Vec<char>> {
    let width = input_lines[0].as_bytes().len();
    let height = input_lines.len();

    // Create empty Vec
    let mut ski_map = vec![vec!['.'; width]; height];

    // Fill with characters from input
    for (row, line) in input_lines.iter().enumerate() {
        for (col, c) in line.chars().enumerate() {
            ski_map[row][col] = c;
        }
    }

    ski_map
}

// Given the `ski_map` and a `slope`, count the number of trees encountered
fn trees_on_slope(ski_map: &Vec<Vec<char>>, slope: (usize, usize)) -> i64 {
    let map_width = ski_map[0].len();
    let mut pos = (0, 0);
    let mut tree_count = 0;

    // Until the 'row' part of our current position is at the bottom of the map
    while pos.0 < ski_map.len() {
        if ski_map[pos.0][pos.1] == '#' {
            tree_count += 1;
        }
        pos.0 += slope.0;
        pos.1 += slope.1;
        if pos.1 >= map_width {
            pos.1 -= map_width;
        }
    }

    tree_count
}

// Count the trees encountered in part one, using the given slope
fn part_one(ski_map: &Vec<Vec<char>>) {
    let trees_found = trees_on_slope(&ski_map, (1, 3));
    println!("\nThe answer to part one is {}.", trees_found);
}

// Find the answer to part two, using the list of slopes
fn part_two(ski_map: &Vec<Vec<char>>) {
    let slopes = [(1, 1), (1, 3), (1, 5), (1, 7), (2, 1)];
    let part_two_total = slopes.iter()
        .map(|x| trees_on_slope(&ski_map, *x))
        .fold(1, |total, next| total * next);
    println!("\nThe answer to part two is {}.", part_two_total);
}

// Timing function, given the function to run and the input arguments, runs
// the function with the given input and prints the time to run to the
// console
fn time_it(f: fn(&Vec<Vec<char>>) -> (), ski_map: &Vec<Vec<char>>) {
    let start = Instant::now();
    f(&ski_map);
    let duration = start.elapsed();

    println!("Solved in: {:?}\n", duration);
}


fn main() {
    // Read in input data
    let input_data = match read_input("../input.txt") {
        Ok(data) => data,
        Err(_) => panic!("Could not read input file."),
    };

    // Parse input data to a 2D Vec
    let ski_map = parse_input(&input_data);

    
    time_it(part_one, &ski_map); // Part One
    time_it(part_two, &ski_map); // Part Two
}
