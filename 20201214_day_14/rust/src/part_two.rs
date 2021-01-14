use crate::instruction::v2::InstructionSet;
use std::io::Error;

pub fn solve(filename: &str) -> Result<(), Error> {
    let instructions = InstructionSet::from_file(filename)?;
    let parsed_instructions = instructions.parsed();
    let answer = parsed_instructions.total();
    println!("\nThe answer to part two is {}", answer);
    Ok(())
}
