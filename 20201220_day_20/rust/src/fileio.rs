use crate::tile::Tile;
use std::fs::File;
use std::io::{BufRead, BufReader, Error, ErrorKind};

pub fn read_input(filename: &str) -> Result<Vec<Tile>, Error> {
    let file = File::open(filename)?;
    let br = BufReader::new(file);
    let mut tile_id: u32 = 0;
    let mut tile_strs: Vec<String> = Vec::with_capacity(10);
    let mut tiles = Vec::new();

    for line in br.lines() {
        let line = line?;
        if line.is_empty() {
            let ref_tile_strs: Vec<&str> = tile_strs.iter().map(|x| x.as_str()).collect();
            let tile = Tile::from_str_vec(tile_id, &ref_tile_strs);
            tiles.push(tile);
            tile_strs.clear();
        } else if line.contains("Tile") {
            tile_id = line[5..=8]
                .parse()
                .map_err(|e| Error::new(ErrorKind::InvalidData, e))?;
        } else {
            tile_strs.push(line);
        }
    }
    Ok(tiles)
}
