use crate::fileio::{expand_rule, tokenize, Messages, Rules};

pub fn solve(rules: &mut Rules, messages: &Messages) {
    let rule8 = tokenize("( 42 )+");
    let rule11 = tokenize("(?<re> 42 \\g<re>? 31 )");
    rules.insert(8, rule8);
    rules.insert(11, rule11);

    let rule0 = expand_rule(0, rules).unwrap();

    let mut matches = 0;
    for msg in messages {
        if rule0.is_match(msg) {
            matches += 1;
        }
    }

    println!("\nThe answer to part two is {}", matches);
}
