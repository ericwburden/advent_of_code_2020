use std::collections::HashSet;
use std::iter::FromIterator;

// Given a Vec of HashSets, return the intersection of all the HashSets
fn group_intersect(group: &Vec<HashSet<char>>) -> HashSet<char> {
    let mut all_set: HashSet<char> = HashSet::new();

    // Seed the final set with the values from the first person in the group
    all_set.extend(&group[0]);  
    for set in group {
        all_set = HashSet::from_iter(all_set.intersection(&set).cloned());
    }

    all_set
}

// For each group, identify the answers provided by *every* person, count them, then sum them
pub fn sum_answer_counts(group_answers: &Vec<Vec<HashSet<char>>>) {
    let sum_group_counts = group_answers.iter()
        .map(|x| group_intersect(x))
        .map(|x| x.len())
        .fold(0, |total, next| total + next);

    println!("\nThe answer to part two is {}", sum_group_counts);
}