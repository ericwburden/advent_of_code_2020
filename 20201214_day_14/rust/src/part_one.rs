use crate::instruction::v1::InstructionSet;
use std::io::Error;

pub fn solve(filename: &str) -> Result<(), Error> {
    let instructions = InstructionSet::from_file(filename)?;
    let parsed_instructions = instructions.parsed();
    let answer = parsed_instructions.total();
    println!("\nThe answer to part one is {}", answer);
    Ok(())
}
