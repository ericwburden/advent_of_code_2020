use std::collections::{HashMap, HashSet};
use std::iter::FromIterator;

pub fn solve(possible_allergen_ingredients: &HashMap<String, HashSet<String>>) {
    // Prepare to compile a mapping of allergens to the ingredient that contains that allergen
    let mut confirmed_allergen_ingredients: HashMap<String, String> = HashMap::new();
    while confirmed_allergen_ingredients.len() < possible_allergen_ingredients.len() {
        // A set of all the ingredients that have been confirmed
        let confirmed_ingredients_set: HashSet<_> =
            HashSet::from_iter(confirmed_allergen_ingredients.values().map(|x| x.clone()));

        // For each combination of allergen and possible ingredients...
        for (allergen, ingredients) in possible_allergen_ingredients.iter() {
            if confirmed_allergen_ingredients.contains_key(allergen) {
                continue; // Skip the allergen if it's already confirmed
            }

            // Get the ingredients for this allergen that aren't already confirmed
            let remaining_ingredients: Vec<_> =
                ingredients.difference(&confirmed_ingredients_set).collect();

            // If there's only one ingredient left, that's the match.
            if remaining_ingredients.len() == 1 {
                let ingredient = remaining_ingredients[0];
                confirmed_allergen_ingredients.insert(allergen.to_string(), ingredient.to_string());
            }
        }
    }

    // Get a sorted list of allergens
    let mut sorted_keys: Vec<_> = confirmed_allergen_ingredients.keys().collect();
    sorted_keys.sort_unstable();

    // Build the ingredient list string
    let mut canonical_dangerous_ingredients = String::new();
    for k in sorted_keys {
        let ingredient = confirmed_allergen_ingredients.get(k).unwrap();
        canonical_dangerous_ingredients.push_str(ingredient);
        canonical_dangerous_ingredients.push(',');
    }
    let l = canonical_dangerous_ingredients.len();

    println!(
        "\nThe answer to part two is {}",
        &canonical_dangerous_ingredients[..(l - 1)]
    );
}
