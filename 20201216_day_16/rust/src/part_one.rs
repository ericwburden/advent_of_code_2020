use crate::input::{Input, InvalidField};

pub fn solve(input: &Input) -> Vec<InvalidField> {
    let invalid_fields = input.get_invalid_fields();
    let answer = invalid_fields
        .iter()
        .map(|x| x.value)
        .fold(0, |total, next| total + next);
    println!("\nThe answer to part one is {}", answer);
    invalid_fields
}
