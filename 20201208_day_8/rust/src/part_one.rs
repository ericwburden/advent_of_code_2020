use crate::instruction::Instruction;
use std::collections::HashSet;

// Iterate through the instructions and run them until hitting an instruction that has been run
// before, then report the accumulator value
pub fn solve(instructions: &Vec<Instruction>) {
    let mut pointer = 0;
    let mut acc = 0;
    let mut pointer_history = HashSet::new();

    loop {
        if pointer_history.insert(pointer) {
            instructions[pointer].execute(&mut pointer, &mut acc);
        } else {
            break;
        }
    }

    println!("The answer to part one is {}", acc);
}
