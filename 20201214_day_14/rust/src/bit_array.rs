use std::hash::{Hash, Hasher};
use std::ops::Index;
use std::slice::Iter;

#[derive(Debug, PartialEq, Eq)]
pub struct BitArray([bool; 36]);

impl BitArray {
    pub fn from_decimal<T: Into<u128>>(decimal: T) -> Self {
        let mut decimal = decimal.into();
        let mut bit_array = [false; 36];

        for idx in (0..36).rev() {
            bit_array[idx] = (decimal % 2) == 1;
            decimal /= 2;
            if decimal == 0 {
                break;
            }
        }

        BitArray(bit_array)
    }

    pub fn from_bool_array(bool_array: [bool; 36]) -> Self {
        BitArray(bool_array)
    }

    pub fn to_decimal(&self) -> u64 {
        let mut decimal: u64 = 0;
        for (i, n) in self.iter().rev().enumerate() {
            if let true = n {
                let exp = i as u32;
                let place_value = u64::pow(2, exp);
                decimal += *n as u64 * place_value;
            }
        }
        decimal
    }

    pub fn iter(&self) -> Iter<bool> {
        self.0.iter()
    }
}

impl Index<usize> for BitArray {
    type Output = bool;

    fn index(&self, index: usize) -> &bool {
        &self.0[index]
    }
}

impl Hash for BitArray {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.to_decimal().hash(state);
    }
}
