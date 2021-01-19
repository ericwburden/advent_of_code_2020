use crate::fileio::{expand_rule, Messages, Rules};

pub fn solve(rules: &Rules, messages: &Messages) {
    let rule0 = expand_rule(0, rules).unwrap();

    let mut matches = 0;
    for msg in messages {
        if rule0.is_match(msg) {
            matches += 1;
        }
    }

    println!("\nThe answer to part one is {}", matches);
}
