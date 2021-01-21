use crate::recipe::Recipe;
use std::collections::{HashMap, HashSet};
use std::iter::FromIterator;

pub fn solve(recipes: Vec<Recipe>) -> HashMap<String, HashSet<String>> {
    // Prepare to compile a listing of allergens with the ingredients that appear in every
    // recipe that the allergen appears in.
    let mut allergen_ingredients: HashMap<String, HashSet<String>> = HashMap::new();
    let mut all_ingredients: Vec<String> = Vec::new();

    // For each recipe...
    for recipe in recipes {
        // Convert each ingredients list to a set
        let ingredients: HashSet<String> = HashSet::from_iter(recipe.ingredients);

        // For each allergen in the recipe...
        for allergen in recipe.allergens {
            // The current set of ingredients for this allergen
            let current_ingredients = allergen_ingredients
                .entry(allergen)
                .or_insert(ingredients.clone());

            // Get the intersection of the ingredients for this allergen and the ingredients for
            // the current recipe
            let ingredients_in_common: HashSet<_> = ingredients
                .intersection(&current_ingredients)
                .map(|x| x.to_string())
                .collect();
            let _ = std::mem::replace(current_ingredients, ingredients_in_common);
        }

        // Add all the ingredients from this recipe to the duplicated list of all ingredients
        for ingredient in ingredients {
            all_ingredients.push(ingredient);
        }
    }

    // Create a set of all ingredients that are associated with at least one allergen
    let mut possible_allergens: HashSet<String> = HashSet::new();
    for ingredient_list in allergen_ingredients.values() {
        for ingredient in ingredient_list {
            possible_allergens.insert(ingredient.to_string());
        }
    }

    // Get a duplicative list of every ingredient that isn't in the set associated with allergens
    let mut safe_ingredients = Vec::new();
    for ingredient in all_ingredients {
        if !possible_allergens.contains(&ingredient[..]) {
            safe_ingredients.push(ingredient);
        }
    }

    println!("\nThe answer to part one is {}", safe_ingredients.len());

    allergen_ingredients
}
