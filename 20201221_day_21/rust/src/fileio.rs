use crate::recipe::Recipe;
use std::fs::File;
use std::io::{BufRead, BufReader, Error};

pub fn read_input(filename: &str) -> Result<Vec<Recipe>, Error> {
    let file = File::open(filename)?;
    let br = BufReader::new(file);
    let mut recipes = Vec::new();

    for line in br.lines() {
        let recipe = Recipe::from_string(line?);
        recipes.push(recipe);
    }

    Ok(recipes)
}
