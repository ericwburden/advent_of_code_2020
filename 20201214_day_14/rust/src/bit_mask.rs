use crate::bit_array::BitArray;
use std::ops::{Index, IndexMut};

pub mod v1 {
    use super::{BitArray, Index, IndexMut};

    #[derive(Debug, Clone, Copy)]
    pub struct BitMask([Option<bool>; 36]);

    impl BitMask {
        pub fn empty() -> Self {
            BitMask([None; 36])
        }

        pub fn from_string(string: &str) -> Self {
            let char_vec: Vec<char> = string.chars().collect();
            let mut mask_array: [Option<bool>; 36] = [None; 36];
            for idx in 0..36 {
                match char_vec[idx] {
                    '1' => mask_array[idx] = Some(true),
                    '0' => mask_array[idx] = Some(false),
                    'X' => continue,
                    _ => panic!("Could not parse {}", char_vec[idx]),
                }
            }
            BitMask(mask_array)
        }

        pub fn apply(&self, bit_array: &BitArray) -> BitArray {
            let mut new_array = [false; 36];
            for idx in 0..36 {
                match self[idx] {
                    Some(x) => new_array[idx] = x,
                    None => new_array[idx] = bit_array[idx],
                }
            }
            BitArray::from_bool_array(new_array)
        }
    }

    impl Index<usize> for BitMask {
        type Output = Option<bool>;

        fn index(&self, index: usize) -> &Option<bool> {
            &self.0[index]
        }
    }

    impl IndexMut<usize> for BitMask {
        fn index_mut(&mut self, index: usize) -> &mut Self::Output {
            &mut self.0[index]
        }
    }
}

pub mod v2 {
    use super::{v1, Index};

    #[derive(Debug, Clone)]
    pub struct BitMask(Vec<v1::BitMask>);

    impl BitMask {
        pub fn empty() -> Self {
            BitMask(Vec::new())
        }

        pub fn len(&self) -> usize {
            self.0.len()
        }

        pub fn from_string(string: &str) -> Self {
            let char_vec: Vec<char> = string.chars().collect();
            let mut masks: Vec<v1::BitMask> = vec![v1::BitMask::empty()];
            for idx in 0..36 {
                match char_vec[idx] {
                    '1' => {
                        for i in 0..masks.len() {
                            masks[i][idx] = Some(true);
                        }
                    }
                    'X' => {
                        let mut new_masks = masks.clone();
                        for i in 0..masks.len() {
                            masks[i][idx] = Some(true);
                            new_masks[i][idx] = Some(false);
                        }
                        masks.extend(new_masks);
                    }
                    '0' => continue,
                    _ => panic!("Could not parse {}", char_vec[idx]),
                }
            }
            BitMask(masks)
        }

        // pub fn apply(&self, bit_array: &BitArray) -> Vec<BitArray> {
        //     let mut new_arrays = Vec::with_capacity(self.0.len());
        //     for mask_idx in 0..self.0.len() {
        //         let mut new_array = [false; 36];
        //         for idx in 0..36 {
        //             match self[mask_idx][idx] {
        //                 Some(x) => new_array[idx] = x,
        //                 None => new_array[idx] = bit_array[idx],
        //             }
        //         }

        //         new_arrays.push(BitArray::from_bool_array(new_array));
        //     }
        //     new_arrays
        // }
    }

    impl Index<usize> for BitMask {
        type Output = v1::BitMask;

        fn index(&self, index: usize) -> &v1::BitMask {
            &self.0[index]
        }
    }

    impl IntoIterator for BitMask {
        type Item = v1::BitMask;
        type IntoIter = std::vec::IntoIter<Self::Item>;

        fn into_iter(self) -> Self::IntoIter {
            self.0.into_iter()
        }
    }
}
