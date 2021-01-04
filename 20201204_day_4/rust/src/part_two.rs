use crate::Passport;

// Validates a Vec of passports according to the Part Two rules and count
// the number of valid passports
pub fn valid_passports(passports: &Vec<Passport>) {
    let valid_count = passports.iter()
        .map(|x| x.part_two_valid())
        .fold(0, |total, next| if next { total + 1 } else { total });

    println!("\nFound {} valid passports, part two.", valid_count);
}