use crate::instruction::Instruction;
use std::collections::HashSet;

// Iterate through the instructions, stopping at the first repeated instruction, returning the
// order of execution up to that point
fn get_run_order(instructions: &Vec<Instruction>) -> Vec<usize> {
    let mut pointer = 0;
    let mut acc = 0;
    let mut pointer_history = HashSet::new();
    let mut instr_order = Vec::with_capacity(instructions.len());

    loop {
        if pointer_history.insert(pointer) {
            instr_order.push(pointer);
            instructions[pointer].execute(&mut pointer, &mut acc);
        } else {
            break;
        }
    }

    instr_order
}

// Given the instruction set `instructions` and an `index` to that instruction set, 'flip' the
// instruction at `index` and test the instruction set to see if it can start from that
// index and successfully finish
pub fn is_instruction_corrupted(instructions: &Vec<Instruction>, index: usize) -> bool {
    loop {
        let mut pointer: usize = index;
        let mut pointer_history = HashSet::new();

        instructions[index].flip_execute(&mut pointer);

        loop {
            if pointer >= instructions.len() {
                return true;
            } else if pointer_history.insert(pointer) {
                instructions[pointer].execute(&mut pointer, &mut 0);
            } else {
                return false;
            }
        }
    }
}

// Get the order in which instructions run (up to the loop), then work backwards over that list
// to find the index that, when flipped, will allow the instruction set to fully execute. With
// that knowledge, run the full instruction set, flipping that corrupted instruction when you
// come to it, and report the final accumulator value.
pub fn solve(instructions: &Vec<Instruction>) {
    let mut run_order = get_run_order(&instructions);
    let corrupted_instruction = loop {
        let index = run_order.pop().unwrap();

        match instructions[index] {
            Instruction::ACC(_) => continue,
            Instruction::JMP(_) | Instruction::NOP(_) => {
                if is_instruction_corrupted(&instructions, index) {
                    break index;
                }
            }
        }
    };

    let mut pointer = 0;
    let mut acc = 0;
    let mut pointer_history = HashSet::new();

    loop {
        if pointer >= instructions.len() {
            break;
        }
        if pointer_history.insert(pointer) {
            if pointer == corrupted_instruction {
                instructions[pointer].flip_execute(&mut pointer);
            } else {
                instructions[pointer].execute(&mut pointer, &mut acc);
            }
            continue;
        }
        panic!("Encountered a loop after correcting the corrupted instruction.");
    }

    println!("\nThe answer to part two is {}", acc);
}
