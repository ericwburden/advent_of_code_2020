use std::fmt::{Debug, Display, Formatter, Result};

pub enum Side {
    Top,
    Bottom,
    Left,
    Right,
}

/// Represents a single tile in the input
#[derive(Clone)]
pub struct Tile {
    pub id: u32,
    pub pixels: Vec<Vec<bool>>,
    width: usize,
    height: usize,
    state: usize,
}

impl Tile {
    /// Creates a Tile from a vector of strings, where each string contains only '#' and '.'
    /// characters.
    pub fn from_str_vec(id: u32, pixel_strs: &[&str]) -> Self {
        let mut width = 0;
        let mut height = 0;
        let mut pixels = Vec::with_capacity(10);
        for row in pixel_strs {
            let mut row_vec = Vec::with_capacity(10);
            for (i, c) in row.chars().enumerate() {
                let pixel = match c {
                    '.' => false,
                    '#' => true,
                    _ => panic!("Cannot convert '{}' to a pixel.", c),
                };
                row_vec.push(pixel);
                if i > width {
                    width = i
                };
            }
            pixels.push(row_vec);
            height += 1;
        }
        width += 1;

        Tile {
            id,
            pixels,
            width,
            height,
            state: 0,
        }
    }

    /// Creates a Tile from a nexted boolean vector
    pub fn from_pixels(id: u32, pixels: Vec<Vec<bool>>) -> Self {
        let height = pixels.len();
        let width = pixels[0].len();

        Tile {
            id,
            pixels,
            width,
            height,
            state: 0,
        }
    }

    /// Shift the contents of Tile.pixels around 90' clockwise and return a Tile with the
    /// re-organized pixels
    fn rotate(&self) -> Self {
        let mut pixels = Vec::with_capacity(self.height);
        for i in 0..self.height {
            let mut new_row = Vec::with_capacity(self.width);
            for j in 0..self.width {
                new_row.push(self.pixels[j][i]);
            }
            new_row.reverse();
            pixels.push(new_row);
        }

        Tile {
            id: self.id,
            pixels,
            width: self.height,
            height: self.width,
            state: self.state + 1,
        }
    }

    /// Flips Tile.pixels across the horizontal axis and returns a Tile with the re-organized
    /// pixels
    fn flip(&self) -> Self {
        let mut pixels = Vec::with_capacity(self.height);
        for row in self.pixels.iter() {
            let mut new_row = row.clone();
            new_row.reverse();
            pixels.push(new_row);
        }

        Tile {
            id: self.id,
            pixels,
            width: self.width,
            height: self.height,
            state: self.state + 1,
        }
    }

    /// Either flips or rotates a tile to yield each of 8 possible permutations in order. Returns
    /// None after the last permutation.
    pub fn next(&self) -> Option<Tile> {
        if self.state == 7 {
            return None;
        } else if self.state == 3 {
            return Some(self.flip());
        } else {
            return Some(self.rotate());
        }
    }

    /// Returns a vector of the 'pixels' (bool) on the given side of Tile.pixels
    pub fn edge(&self, side: &Side) -> Vec<bool> {
        let mut side_vec = Vec::with_capacity(self.height);
        match side {
            Side::Left => {
                for r in 0..self.height {
                    side_vec.push(self.pixels[r][0]);
                }
            }
            Side::Top => {
                side_vec = self.pixels[0].clone();
            }
            Side::Right => {
                for r in 0..self.height {
                    side_vec.push(self.pixels[r][self.width - 1]);
                }
            }
            Side::Bottom => {
                side_vec = self.pixels[self.height - 1].clone();
            }
        }
        side_vec
    }

    /// Compares the pixels on the given side of a tile to the corresponding side of an 'other'
    /// tile. Translates the other tile through all possible permutations checking for a match.
    pub fn match_tile(&self, side: &Side, other: &Tile) -> Option<Tile> {
        let edge = self.edge(side);
        let mut some_other_tile = Some(other.clone());
        let other_side = match side {
            Side::Top => Side::Bottom,
            Side::Bottom => Side::Top,
            Side::Left => Side::Right,
            Side::Right => Side::Left,
        };

        loop {
            match some_other_tile {
                Some(t) => {
                    let other_edge = t.edge(&other_side);
                    let match_count = edge.iter().zip(&other_edge).filter(|(a, b)| a == b).count();
                    if match_count == edge.len() {
                        return Some(t);
                    } else {
                        some_other_tile = t.next();
                    }
                }
                None => return None,
            }
        }
    }

    /// Given a list of tiles, compares the given side of this tile to each of the permutations of
    /// each of the other tiles, returning Some(Tile) if a match is found, otherwise None.
    pub fn find_tile_match(&self, side: &Side, tiles: &[&Tile]) -> Option<Tile> {
        for tile in tiles {
            match self.match_tile(side, *tile) {
                Some(t) => return Some(t),
                None => continue,
            }
        }
        None
    }
}

impl Display for Tile {
    fn fmt(&self, f: &mut Formatter) -> Result {
        writeln!(
            f,
            "Tile ID: {} ({}x{}); State: {}",
            self.id, self.height, self.width, self.state
        )?;
        for row in self.pixels.iter() {
            for pixel in row {
                match pixel {
                    true => write!(f, "#")?,
                    false => write!(f, ".")?,
                }
            }
            writeln!(f, "")?;
        }
        writeln!(f, "")
    }
}

impl Debug for Tile {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        f.debug_struct("Tile").field("id", &self.id).finish()
    }
}
