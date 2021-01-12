use std::fs::File;
use std::io::{BufRead, BufReader, Error};

#[derive(Clone, Copy, Debug)]
pub enum Action {
    North(i32),
    South(i32),
    East(i32),
    West(i32),
    Left(i32),
    Right(i32),
    Forward(i32),
}

impl Action {
    pub fn from_string(s: &str) -> Self {
        let action = s[..1].trim(); // The alpha part
        let value = s[1..].trim().parse().unwrap(); // The numeric part

        // Convert to Action based on the alpha part
        match action {
            "N" => Action::North(value),
            "S" => Action::South(value),
            "E" => Action::East(value),
            "W" => Action::West(value),
            "L" => Action::Left(value),
            "R" => Action::Right(value),
            "F" => Action::Forward(value),
            _ => panic!("Can't parse Action from {}", s),
        }
    }
}

#[derive(Clone, Debug)]
pub struct Manifest(Vec<Action>);

impl Manifest {
    pub fn from_file(filename: &str) -> Result<Self, Error> {
        let file = File::open(&filename)?; // Open file or panic
        let br = BufReader::new(file); // Create read buffer
        let mut v: Manifest = Manifest::new(); // Initialize empty vector

        // For each line in the input file...
        for line in br.lines() {
            let line_string = line?.trim().to_string();
            let action = Action::from_string(&line_string);
            v.push(action);
        }

        return Ok(v); // Return data
    }

    pub fn new() -> Self {
        Self(Vec::new())
    }
}

impl IntoIterator for Manifest {
    type Item = Action;
    type IntoIter = std::vec::IntoIter<Self::Item>;

    fn into_iter(self) -> Self::IntoIter {
        self.0.into_iter()
    }
}

// Needed to access Manifest's inner Vec methods immutably
impl std::ops::Deref for Manifest {
    type Target = Vec<Action>;
    fn deref(&self) -> &Vec<Action> {
        &self.0
    }
}

// Needed to access Manifest's inner Vec methods mutably
impl std::ops::DerefMut for Manifest {
    fn deref_mut(&mut self) -> &mut Vec<Action> {
        &mut self.0
    }
}
