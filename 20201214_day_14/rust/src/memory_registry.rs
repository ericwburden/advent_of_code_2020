use crate::bit_array::BitArray;
use crate::bit_mask::v1::BitMask;
use std::collections::HashMap;

pub mod v1 {
    use super::*;

    #[derive(Debug)]
    pub struct MemoryRegistry(HashMap<u64, BitArray>);

    impl MemoryRegistry {
        pub fn new() -> Self {
            MemoryRegistry(HashMap::with_capacity(600))
        }

        pub fn write_masked<T: Into<u128>>(
            &mut self,
            addr: u64,
            value: T,
            mask: &BitMask,
        ) -> Option<BitArray> {
            let bit_array = BitArray::from_decimal(value);
            let masked_array = mask.apply(&bit_array);
            self.0.insert(addr, masked_array)
        }

        pub fn total(&self) -> u64 {
            let mut total = 0;
            for (_, val) in self.0.iter() {
                total += val.to_decimal();
            }
            total
        }
    }
}

pub mod v2 {
    use super::*;
    use fnv::FnvHashMap;

    #[derive(Debug)]
    pub struct MemoryRegistry(FnvHashMap<BitArray, u64>);

    impl MemoryRegistry {
        pub fn new() -> Self {
            // MemoryRegistry(HashMap::with_capacity(80_000))
            MemoryRegistry(FnvHashMap::with_capacity_and_hasher(
                80_000,
                Default::default(),
            ))
        }

        pub fn write_masked<T: Into<u128>>(
            &mut self,
            addr: T,
            value: u64,
            mask: &BitMask,
        ) -> Option<u64> {
            let bit_array = BitArray::from_decimal(addr);
            let masked_array = mask.apply(&bit_array);
            self.0.insert(masked_array, value)
        }

        pub fn total(&self) -> u64 {
            let mut total = 0;
            for (_, val) in self.0.iter() {
                total += val;
            }
            total
        }
    }
}
