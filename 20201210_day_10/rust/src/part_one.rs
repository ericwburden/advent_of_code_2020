/// Given a Vec of numbers `nums`, return a Vec representing the numeric difference between each
/// number and the number before it in sequence.
pub fn get_jolt_diffs(adapters: &Vec<u8>) -> Vec<u8> {
    let mut jolt_diffs = Vec::with_capacity(adapters.len() + 1);

    // Assume `0` for the number 'prior to' the start of the list
    for (i, n) in adapters.iter().enumerate() {
        let diff = if i == 0 { *n } else { n - adapters[i - 1] };
        jolt_diffs.push(diff);
    }
    jolt_diffs.push(3); // The last diff is always 3, by the puzzle rules
    jolt_diffs
}

/// Solve puzzle part one
pub fn solve(adapters: &Vec<u8>) {
    let jolt_diffs = get_jolt_diffs(adapters);
    let mut ones = 0; // Count of jolt_diffs == 1
    let mut threes = 0; // Count of jolt_diffs == 3

    // Count up the number of `1`'s and `3`'s
    for d in jolt_diffs {
        match d {
            1 => ones += 1,
            3 => threes += 1,
            _ => continue,
        }
    }

    println!("The answer to part one is {}", ones * threes);
}
