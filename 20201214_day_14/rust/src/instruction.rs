use std::fs::File;
use std::io::{BufRead, BufReader, Error, ErrorKind};

pub mod v1 {
    use super::*;
    use crate::bit_mask::v1::BitMask;
    use crate::memory_registry::v1::MemoryRegistry;

    #[derive(Debug)]
    pub enum Instruction {
        Mask(BitMask),
        Assignment((u64, u64)),
    }

    #[derive(Debug)]
    pub struct InstructionSet(Vec<Instruction>);

    impl InstructionSet {
        pub fn from_file(filename: &str) -> Result<Self, Error> {
            let file = File::open(&filename)?; // Open file or panic
            let br = BufReader::new(file); // Create read buffer
            let mut instructions = Vec::new();

            // For each line in the input file...
            for line in br.lines() {
                let line_string = line?.trim().to_string();
                if line_string.contains("mask") {
                    let mask = BitMask::from_string(&line_string[7..]);
                    instructions.push(Instruction::Mask(mask));
                } else {
                    let line_string_parts: Vec<&str> = line_string.split(" = ").collect();
                    let addr_part = line_string_parts[0];
                    let addr: u64 = addr_part[4..(addr_part.len() - 1)]
                        .parse()
                        .map_err(|e| Error::new(ErrorKind::InvalidData, e))?;
                    let val_part = line_string_parts[1];
                    let val: u64 = val_part
                        .parse()
                        .map_err(|e| Error::new(ErrorKind::InvalidData, e))?;

                    instructions.push(Instruction::Assignment((addr, val)));
                }
            }

            return Ok(InstructionSet(instructions)); // Return data
        }

        pub fn parsed(&self) -> MemoryRegistry {
            let mut current_mask = BitMask::empty();
            let mut memory_registry = MemoryRegistry::new();

            for instruction in &self.0 {
                match instruction {
                    Instruction::Mask(m) => {
                        current_mask = *m;
                    }
                    Instruction::Assignment(a) => {
                        memory_registry.write_masked(a.0, a.1, &current_mask);
                    }
                }
            }
            memory_registry
        }
    }
}

pub mod v2 {
    use super::*;
    use crate::bit_mask::v2::BitMask;
    use crate::memory_registry::v2::MemoryRegistry;

    #[derive(Debug)]
    pub enum Instruction {
        Mask(BitMask),
        Assignment((u64, u64)),
    }

    #[derive(Debug)]
    pub struct InstructionSet(Vec<Instruction>);

    impl InstructionSet {
        /// This *looks* exactly the same as the v1::InstructionSet version, but keep in mind it's
        /// using the v2::BitMask and v2::BitMask parsing here.
        pub fn from_file(filename: &str) -> Result<Self, Error> {
            let file = File::open(&filename)?; // Open file or panic
            let br = BufReader::new(file); // Create read buffer
            let mut instructions = Vec::new();

            // For each line in the input file...
            for line in br.lines() {
                let line_string = line?.trim().to_string();
                if line_string.contains("mask") {
                    let mask = BitMask::from_string(&line_string[7..]);
                    instructions.push(Instruction::Mask(mask));
                } else {
                    let line_string_parts: Vec<&str> = line_string.split(" = ").collect();
                    let addr_part = line_string_parts[0];
                    let addr: u64 = addr_part[4..(addr_part.len() - 1)]
                        .parse()
                        .map_err(|e| Error::new(ErrorKind::InvalidData, e))?;
                    let val_part = line_string_parts[1];
                    let val: u64 = val_part
                        .parse()
                        .map_err(|e| Error::new(ErrorKind::InvalidData, e))?;

                    instructions.push(Instruction::Assignment((addr, val)));
                }
            }

            return Ok(InstructionSet(instructions)); // Return data
        }

        pub fn parsed(&self) -> MemoryRegistry {
            let mut current_mask = &BitMask::empty();
            let mut memory_registry = MemoryRegistry::new();

            for instruction in &self.0 {
                match instruction {
                    Instruction::Mask(m) => {
                        current_mask = m;
                    }
                    Instruction::Assignment(a) => {
                        for mask_idx in 0..current_mask.len() {
                            memory_registry.write_masked(a.0, a.1, &current_mask[mask_idx]);
                        }
                    }
                }
            }
            memory_registry
        }
    }
}
