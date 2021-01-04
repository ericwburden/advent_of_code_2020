use std::collections::HashSet;

// Given a Vec of HashSets, return the union of all the HashSets
fn group_union(group: &Vec<HashSet<char>>) -> HashSet<char> {
    let mut any_set = HashSet::new();
    for set in group {
        for c in set {
            any_set.insert(*c);
        }
    }

    any_set
}

// For each group, identify the answers provided by any person, count them, then sum them
pub fn sum_answer_counts(group_answers: &Vec<Vec<HashSet<char>>>) {
    let sum_group_counts = group_answers.iter()
        .map(|x| group_union(x))
        .map(|x| x.len())
        .fold(0, |total, next| total + next);

    println!("\nThe answer to part one is {}", sum_group_counts);
}