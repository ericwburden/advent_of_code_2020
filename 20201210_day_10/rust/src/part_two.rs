use cached::proc_macro::cached;

/// Calculate the run length of each number in a Vec of numbers `nums`
fn run_length_encode(nums: &Vec<u8>) -> Vec<(u8, u16)> {
    let mut run_lengths = Vec::with_capacity(nums.len());
    let mut current = (nums[0], 0); // Represent each run length as a tuple (number, run length)

    // Iterate through `num` and calculate run lenghts for each element
    for n in nums {
        if *n == current.0 {
            current.1 += 1;
        } else {
            run_lengths.push(current);
            current.0 = *n;
            current.1 = 1;
        }
    }

    run_lengths.shrink_to_fit(); // Contract the Vec
    run_lengths
}

/// Turns out, the number of ways a number of ways a sequence of `1`'s `n` can be combined to
/// create a sequence of values no greater than `3` is the `n`th tribonacci number.
#[cached]
fn tribonacci(n: u16) -> u64 {
    if n < 3 {
        return n as u64;
    }
    return tribonacci(n - 1) + tribonacci(n - 2) + tribonacci(n - 3);
}

/// Solve puzzle part two
pub fn solve(adapters: &Vec<u8>) {
    let jolt_diffs = crate::part_one::get_jolt_diffs(adapters);
    let run_lengths = run_length_encode(&jolt_diffs);

    // Will hold a list of the number of combinations contributed by each run of `1`'s
    let mut combinations = Vec::with_capacity(run_lengths.len());

    // Build the list of combination contributions
    for rl in run_lengths {
        if rl.0 == 1 {
            let combo = tribonacci(rl.1);
            combinations.push(combo);
        }
    }

    // Multiply together the elements of `combinations`
    let answer = combinations.iter().fold(1u64, |total, next| total * next);
    println!("The answer to part two is {}", answer);
}
