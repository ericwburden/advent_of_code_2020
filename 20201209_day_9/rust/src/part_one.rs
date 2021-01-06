use cached::proc_macro::cached;
use cached::SizedCache;

/// Given a target number `total`, a list of numbers `nums`, and a current recursion depth `depth`,
/// check through `num` to find two numbers that sum to `total` and return a boolean indicating
/// whether these two numbers can be found.
fn can_two_sum(total: usize, nums: &Vec<usize>, depth: u8) -> bool {
    if total == 0 {
        return true;
    }
    if depth > 1 {
        return false;
    } // `depth` > 1 indicates the third or more number

    // For each `n` in `nums`, subtract `n` from `total` and continue the search through
    // `nums`. If `total` - `n` would be less than zero, skip this `n`.
    for (i, n) in nums.iter().enumerate() {
        let remainder = match total.checked_sub(*n) {
            None => continue,
            Some(x) => x,
        };

        // Need to check all the numbers in `nums` *except* for the current number, to avoid
        // returning `true` in cases where `total` is exactly double `n`. There's probably a
        // more efficient implementation of this.
        let mut sum_pool: Vec<usize> = Vec::with_capacity(nums.len());
        sum_pool.extend(&nums[..i]);
        sum_pool.extend(&nums[(i + 1)..]);

        if can_two_sum(remainder, &sum_pool, depth + 1) {
            return true;
        }
    }

    false
}

/// Given a list of numbers `nums` and the size of the preamble `preamble` (see puzzle
/// description), identify the first number in `nums` that is not the sum of two of the
/// `preamble`-length preceding numbers.
#[cached(
    type = "SizedCache<String, usize>",
    create = "{ SizedCache::with_size(100) }",
    convert = r#"{ format!("{:?}{}", nums, preamble) }"#
)]
pub fn first_invalid_index(nums: &Vec<usize>, preamble: usize) -> usize {
    let mut check_index = preamble; // Start with the number after the preamble

    loop {
        if check_index > nums.len() {
            panic!("Could not identify an invalid number, part one!");
        }

        // Create a new sub-vector of the size `preamble` to check over
        let check_range = (check_index - preamble)..(check_index);
        let mut check_vec = vec![0; preamble];
        check_vec.clone_from_slice(&nums[check_range]);

        // Test to see if we can find two numbers that sum to the number at `nums[check_index]`
        if !can_two_sum(nums[check_index], &check_vec, 0) {
            break;
        }
        check_index += 1;
    }

    check_index
}

/// Solve part one and report the result.
pub fn solve(nums: &Vec<usize>, preamble: usize) {
    let inv_index = first_invalid_index(nums, preamble);

    println!("\nThe answer to part one is {}", nums[inv_index]);
}
