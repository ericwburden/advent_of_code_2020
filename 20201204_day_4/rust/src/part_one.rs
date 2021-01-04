use crate::Passport;

// Validates a Vec of passports according to the Part One rules and count
// the number of valid passports
pub fn valid_passports(passports: &Vec<Passport>) {
    let valid_count = passports.iter()
        .map(|x| x.part_one_valid())
        .fold(0, |total, next| if next { total + 1 } else { total });

    println!("\nFound {} valid passports, part one.", valid_count);
}