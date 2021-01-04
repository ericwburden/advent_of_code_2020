use std::collections::HashMap;

// Caching wouldn't help here, since we won't encounter the same bag type in a loop, which would
// break not only our code, but also the space-time continuum, probably. Given the name of a 
// bag `name`, recursively check that bag's listing to count how many bags it could theoretically
// hold
fn bag_can_hold(name: &str, bags: &HashMap<String, HashMap<String, u32>>) -> u32 {

    // If `name is empty, return 0
    let contents = match bags.get(name) {
        None => return 0,
        Some(x) => x,
    };

    // Recursively check through each child bag and count the number of bags that could be 
    // contained
    let mut total_bags = 0;
    for (key, val) in contents.iter() {
        let result = bag_can_hold(key, bags);
        total_bags += (result * val) + val;  // Count child bags plus their contents
    }

    total_bags  // How many bags?
}

// Given a bag name `name` and the listing of bag rules `bags`, count the number of bags that
// could be theoretically contained and report the results.
pub fn solve(name: &str, bags: &HashMap<String, HashMap<String, u32>>) {
    let bags_inside = bag_can_hold(name, bags);

    println!("\nOne {} can hold {} bags, part two.", name, bags_inside);
}