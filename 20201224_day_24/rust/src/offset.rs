use lazy_static::lazy_static;
use regex::Regex;
use std::ops::{Add, AddAssign};

lazy_static! {
    static ref RE_DIR: Regex = Regex::new(r"(e|w|[ns][ew])").unwrap();
}

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
pub struct Offset {
    x: i16,
    y: i16,
    z: i16,
}

impl Offset {
    pub fn new() -> Self {
        Offset { x: 0, y: 0, z: 0 }
    }

    pub fn from(dir_str: &str) -> Self {
        let mut base = Offset::new();
        for dir in RE_DIR.captures_iter(dir_str) {
            let s = dir.get(0).unwrap().as_str();
            let offset = match s {
                "nw" => Offset { x: 0, y: 1, z: -1 },
                "ne" => Offset { x: 1, y: 0, z: -1 },
                "e" => Offset { x: 1, y: -1, z: 0 },
                "se" => Offset { x: 0, y: -1, z: 1 },
                "sw" => Offset { x: -1, y: 0, z: 1 },
                "w" => Offset { x: -1, y: 1, z: 0 },
                _ => panic!("Don't know how to parse {}", s),
            };
            base += offset;
        }

        base
    }

    pub fn neighbors(&self) -> Vec<Offset> {
        vec![
            Offset { x: 0, y: 1, z: -1 } + self,
            Offset { x: 1, y: 0, z: -1 } + self,
            Offset { x: 1, y: -1, z: 0 } + self,
            Offset { x: 0, y: -1, z: 1 } + self,
            Offset { x: -1, y: 0, z: 1 } + self,
            Offset { x: -1, y: 1, z: 0 } + self,
        ]
    }
}

impl Add for Offset {
    type Output = Self;

    fn add(self, other: Self) -> Self {
        Self {
            x: self.x + other.x,
            y: self.y + other.y,
            z: self.z + other.z,
        }
    }
}

impl Add<&Offset> for Offset {
    type Output = Self;

    fn add(self, other: &Offset) -> Offset {
        Self {
            x: self.x + other.x,
            y: self.y + other.y,
            z: self.z + other.z,
        }
    }
}

impl AddAssign for Offset {
    fn add_assign(&mut self, other: Self) {
        *self = Self {
            x: self.x + other.x,
            y: self.y + other.y,
            z: self.z + other.z,
        };
    }
}
