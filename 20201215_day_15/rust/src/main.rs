use std::time::Instant;

fn number_spoken(start: &Vec<u32>, upper_limit: usize) -> u32 {
    let ul_u32 = upper_limit as u32;
    let mut mem = vec![ul_u32; upper_limit];
    for (i, &v) in start.iter().enumerate() {
        mem[v as usize] = i as u32;
    }

    let mut prev = *start.last().unwrap();
    for turn in start.len()..upper_limit {
        let spoken = if mem[prev as usize] == ul_u32 {
            0
        } else {
            turn as u32 - mem[prev as usize] - 1
        };
        mem[prev as usize] = turn as u32 - 1;
        prev = spoken;
    }
    prev
}

fn main() {
    let starting_nums = vec![2, 0, 1, 7, 4, 14, 18];

    let start = Instant::now();
    println!(
        "The answer to part one is {}",
        number_spoken(&starting_nums, 2020)
    );
    println!("Solved in: {:?}\n", start.elapsed());

    let start = Instant::now();
    println!(
        "The answer to part two is {}",
        number_spoken(&starting_nums, 30_000_000)
    );
    println!("Solved in: {:?}\n", start.elapsed());
}
