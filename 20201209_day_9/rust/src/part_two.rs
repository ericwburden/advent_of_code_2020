/// Given a list of numbers `nums`, a target number `total`, and a starting index `i`, repeatedly
/// check `num` for a range starting at `i` that sums to `total`, increasing the size of that
/// range through the end of `nums`.
fn check_index(nums: &Vec<usize>, total: usize, i: usize) -> Option<&[usize]> {
    let mut next_i = i + 2; // Each range should include at least two numbers

    // Until reaching the end of `nums`...
    while next_i <= nums.len() {
        // Sum the numbers from `i` to `next_i`
        let current_sum = nums[i..next_i].iter().fold(0, |total, next| total + next);

        if current_sum == total {
            return Some(&nums[i..next_i]);
        }
        if current_sum > total {
            return None;
        }
        next_i += 1;
    }

    None
}

/// Solve part two and report the results
/// Given a list of numbers `nums` and the size of the preamble `preamble`, identify the first
/// invalid number (according to the part one rules), then iterate backwards through the list of
/// `nums` to find a range that sums to the first invalid number.
pub fn solve(nums: &Vec<usize>, preamble: usize) {
    let invalid_index = crate::part_one::first_invalid_index(nums, preamble);
    let total = nums[invalid_index];

    // Work backwards through `nums`
    let mut i = nums.len();
    loop {
        // Try to get a slice from `nums` that sums to `total` starting at `i`. If we fail on the
        // first index, then no solution exists
        let sum_slice = match check_index(nums, total, i) {
            None => {
                i = match i.checked_sub(1) {
                    None => panic!("Could not solve part two!"),
                    Some(x) => x,
                };
                continue;
            }
            Some(x) => x,
        };

        let min_num = sum_slice
            .iter() // The minimum number in the list
            .fold(total, |min, next| if next < &min { *next } else { min });

        let max_num = sum_slice
            .iter() // The maximum number in the list
            .fold(0, |max, next| if next > &max { *next } else { max });

        println!("\nThe answer to part two is {}", min_num + max_num);
        break;
    }
}
