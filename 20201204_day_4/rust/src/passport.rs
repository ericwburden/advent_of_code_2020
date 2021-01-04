// This module contains the data structures for each passport and associated
// methods.

use regex::Regex;

// Height in inches (IN), centimeters (CM), or undefined (UND)
#[derive(Debug)]
enum HeightKind { IN, CM, UND }

// Struct holds height and units
#[derive(Debug)]
struct Height {
    kind: HeightKind,
    value: u16,
}

// Struct to hold passport fields
#[derive(Debug)]
pub struct Passport {
    byr: Option<u16>, // Birth Year
    iyr: Option<u16>, // Issue Year
    eyr: Option<u16>, // Expiration Year
    hgt: Option<Height>, // Height
    hcl: Option<String>, // Hair color
    ecl: Option<String>, // Eye color
    pid: Option<String>, // Passport ID
    cid: Option<String> // Optional Country ID
}

// Passport methods
impl Passport {
    // New passport with blank fields
    fn new() -> Passport {
        Passport {
            byr: None,
            iyr: None,
            eyr: None,
            hgt: None, 
            hcl: None,
            ecl: None,
            pid: None,
            cid: None
        }
    }

    // Parses a "ccc:nnnn" string into a year number
    fn parse_yr(string: &str) -> Option<u16> {
        match string[4..].trim().parse() {
            Ok(x) => Some(x),
            Err(_) => panic!("Could not parse a year from {}", string),
        }
    }

    // Parses a "ccc:nnnuu" string to a Height
    fn parse_height(string: &str) -> Option<Height> {
        let strlen = string.len();
        let last_two = &string[strlen-2..strlen];
        let height_kind = if last_two == "in" {
            HeightKind::IN
        } else if last_two == "cm" {
            HeightKind::CM
        } else {
            HeightKind::UND
        };
        let value = match height_kind {
            HeightKind::IN | HeightKind::CM => &string[4..strlen-2],
            HeightKind::UND => &string[4..],
        };
        match value.parse() {
            Ok(x) => Some(Height {kind: height_kind, value: x}),
            Err(_) => panic!("Could not parse height from {}", string)
        }
    }

    // Parses a "ccc:anything" string to a String
    fn parse_string(string: &str) -> Option<String> {
        Some(string[4..].trim().to_string())
    }

    // Creates a Passport out of String from the input representing a passport
    pub fn from_line(line: &str) -> Passport {
        let mut new_passport = Passport::new();

        // For each field name:value in the input line, parse out the 
        // appropriate field and put it in the blank Passport
        for field in line.trim().split(" ") {
            let field_name = &field[..3];
            if field_name == "byr" {
                new_passport.byr = Passport::parse_yr(field);
            }
            if field_name == "iyr" {
                new_passport.iyr = Passport::parse_yr(field);
            }
            if field_name == "eyr" {
                new_passport.eyr = Passport::parse_yr(field);
            }
            if field_name == "hgt" {
                new_passport.hgt = Passport::parse_height(field);
            }
            if field_name == "hcl" {
                new_passport.hcl = Passport::parse_string(field);
            }
            if field_name == "ecl" {
                new_passport.ecl = Passport::parse_string(field);
            }
            if field_name == "pid" {
                new_passport.pid = Passport::parse_string(field);
            }
            if field_name == "cid" {
                new_passport.cid = Passport::parse_string(field);
            }
        }

        new_passport
    }

    // Checks the validity of the passport according to Part One rules
    pub fn part_one_valid(&self) -> bool {
        if self.byr.is_none() || 
        self.iyr.is_none() || 
        self.eyr.is_none() || 
        self.hgt.is_none() || 
        self.hcl.is_none() ||
        self.ecl.is_none() ||
        self.pid.is_none() {
            return false;
        };

        true
    }

    // Checks the validity of the passport according to Part Two rules
    pub fn part_two_valid(&self) -> bool {

        // This prevents compiling the regular expressions on each loop, vastly
        // increasing performance
        lazy_static! {
            static ref HCL_RE: Regex = Regex::new(r"^#[0-9a-f]{6}$").unwrap();
            static ref ECL_RE: Regex = Regex::new(r"^amb|blu|brn|gry|grn|hzl|oth$").unwrap();
            static ref PID_RE: Regex = Regex::new(r"^\d{9}$").unwrap();
        }

        // Validate `byr` field
        let byr = match self.byr { Some(x) => x, None => return false };
        if byr < 1920 || byr > 2002 { return false; }

        // Validate `iyr` field
        let iyr = match self.iyr { Some(x) => x, None => return false };
        if iyr < 2010 || iyr > 2020 { return false; }

        // Validate `eyr` field
        let eyr = match self.eyr { Some(x) => x, None => return false };
        if eyr < 2020 || eyr > 2030 { return false; }

        // Validate `hgt` field
        let hgt = match &self.hgt { Some(x) => x, None => return false };
        let hgt_valid = match hgt.kind {
            HeightKind::IN => hgt.value >= 59 && hgt.value <= 76,
            HeightKind::CM => hgt.value >= 150 && hgt.value <= 193,
            HeightKind::UND => return false,
        };
        if !hgt_valid { return false; }

        // Validate `hcl` field
        let hcl = match &self.hcl { Some(x) => x, None => return false };
        if !HCL_RE.is_match(hcl) { return false; }

        // Validate `ecl` field
        let ecl = match &self.ecl { Some(x) => x, None => return false };
        if !ECL_RE.is_match(ecl) { return false; }

        // Validate `pid` field
        let pid = match &self.pid { Some(x) => x, None => return false };
        if !PID_RE.is_match(pid) { return false; }

        true  // No validation for `cid`
    }
}