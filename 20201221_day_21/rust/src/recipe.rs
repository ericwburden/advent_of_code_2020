use std::fmt;

/// Provides a structure for storing data about each line in the input file
#[derive(Debug)]
pub struct Recipe {
    pub allergens: Vec<String>,
    pub ingredients: Vec<String>,
}

impl Recipe {
    /// Returns a Recipe struct given a line from the input file
    pub fn from_string(line: String) -> Self {
        let mod_str = line
            .replace(" (contains ", "|")
            .replace(")", "")
            .replace(",", "");
        let str_parts: Vec<&str> = mod_str.split('|').collect();

        let mut ingredients = Vec::new();
        for ingredient in str_parts[0].split(' ') {
            ingredients.push(ingredient.to_string());
        }

        let mut allergens = Vec::new();
        for allergen in str_parts[1].split(' ') {
            allergens.push(allergen.to_string());
        }

        Recipe {
            allergens,
            ingredients,
        }
    }
}

impl fmt::Display for Recipe {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        writeln!(f, "Recipe {{")?;
        writeln!(f, "\tallergens: {:?}", self.allergens)?;
        writeln!(f, "\tingredients: {:?}", self.ingredients)?;
        writeln!(f, "}}")
    }
}
