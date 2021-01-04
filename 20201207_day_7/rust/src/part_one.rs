use std::collections::HashMap;
use cached::proc_macro::cached;
use cached::SizedCache;

// Only hash the `bag` and `contains` arguments when caching, can't hash the complex HashMap by 
// default. Caching prevents the need to recursively search bags that have been searched before.
#[cached(
    type = "SizedCache<String, bool>",
    create = "{ SizedCache::with_size(1000) }",
    convert = r#"{ format!("{}{}", bag, contains) }"#
)]
// Given a bag to search `bag`, a bag to find `contains` and the map of bag rules, can `contains`
// be found in `bag`?
fn bag_contains(bag: &str, contains: &str, bags: &HashMap<String, HashMap<String, u32>>) -> bool {

    // If `bag` not in the list of bag rules, or is empty, return false
    let contents = match bags.get(bag) {
        None => return false,
        Some(x) => x,
    };

    // Recursively search through all the bags in `bag` for `contains`
    for key in contents.keys() {
        if key == contains { return true; }
        if bag_contains(key, contains, bags) { return true; }
    }

    false  // Didn't find it
}

// For each bag type, search that bag for `name`, and count up the total number
// of bags in which it can be found and report the results.
pub fn solve(name: &str, bags: &HashMap<String, HashMap<String, u32>>) {
    let containing_bags_count = bags.keys()
        .map(|k| bag_contains(k, name, bags))
        .fold(0, |total, next| if next { total + 1 } else { total });

    println!("\n{} bags can hold a {}, part one", containing_bags_count, name);
}