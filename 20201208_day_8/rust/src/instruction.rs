// Struct that defines an 'instruction', i.e. a line from the input file
#[derive(Debug)]
pub enum Instruction {
    ACC(i32),
    JMP(i32),
    NOP(i32),
}

impl Instruction {
    // Create an Instruction from an input file line
    pub fn from_string(s: &str) -> Instruction {
        let instruction = s[..4].trim(); // The alpha part
        let value = s[4..].trim().parse().unwrap(); // The numeric part

        // Convert to Instruction based on the alpha part
        match instruction {
            "acc" => Instruction::ACC(value),
            "jmp" => Instruction::JMP(value),
            "nop" => Instruction::NOP(value),
            _ => panic!("Can't parse Instruction from {}", s),
        }
    }

    // Given a mutable reference to a line number in the instruction set `pointer` and a mutable
    // reference to an accumulator `acc`, update `pointer` and `acc` based on the desired
    // Instruction behavior (i.e., Instruction::ACC moves one instruction forward and adds its
    // value to the accumulator).
    pub fn execute(&self, pointer: &mut usize, acc: &mut i32) {
        match self {
            Instruction::ACC(x) => {
                *pointer += 1;
                *acc += x;
            }
            Instruction::JMP(x) => *pointer = (*pointer as i32 + x) as usize,
            Instruction::NOP(_) => *pointer += 1,
        }
    }

    // Given a mutable reference to a line number in the instruction set `pointer`, run the
    // Instruction (JMP or NOP) as if it were the other one (NOP or JMP). Ignore ACC instructions
    pub fn flip_execute(&self, pointer: &mut usize) {
        match self {
            Instruction::ACC(_) => (),
            Instruction::JMP(x) => Instruction::NOP(*x).execute(pointer, &mut 0),
            Instruction::NOP(x) => Instruction::JMP(*x).execute(pointer, &mut 0),
        }
    }
}
