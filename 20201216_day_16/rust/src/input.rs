use std::collections::HashMap;
use std::fs::File;
use std::io::{BufRead, BufReader, Error, ErrorKind};
use std::ops::Range;

/// Produces a closure that tests if a number is in one of a pair of ranges
pub fn field_test_fn(range1: Range<u32>, range2: Range<u32>) -> Box<dyn Fn(&u32) -> bool> {
    Box::new(move |n: &u32| range1.contains(&n) || range2.contains(&n))
}

#[derive(Debug)]
pub enum ParseMode {
    Test,
    MyTicket,
    OtherTicket,
}

#[derive(Debug)]
pub struct InvalidField {
    pub ticket_no: usize,
    pub field_no: usize,
    pub value: u32,
}

pub struct Input {
    pub field_tests: HashMap<String, Box<dyn Fn(&u32) -> bool>>,
    pub my_ticket: Vec<u32>,
    pub nearby_tickets: Vec<Vec<u32>>,
}

impl Input {
    #[rustfmt::skip]
    pub fn from_file(filename: &str) -> Result<Self, Error> {
        let file = File::open(&filename)?;
        let br = BufReader::new(file);
        let mut field_tests = HashMap::new();
        let mut my_ticket = Vec::new();
        let mut nearby_tickets = Vec::new();
        let mut parse_mode = ParseMode::Test;
        let invalid_data_map = |e| Error::new(ErrorKind::InvalidData, e);

        for line in br.lines() {
            let line_string = line?.trim().to_string();
            if line_string == "" { continue; }
            if line_string.contains("your ticket") { parse_mode = ParseMode::MyTicket; continue; }
            if line_string.contains("nearby tickets") {
                parse_mode = ParseMode::OtherTicket;
                continue;
            }
            match parse_mode {
                ParseMode::Test => {
                    let line_string_parts: Vec<&str> = line_string.split(": ").collect();
                    let fn_name = line_string_parts[0].to_string();
                    let ranges: Vec<&str> = line_string_parts[1].split(" or ").collect();
                    let range_one_parts: Vec<&str> = ranges[0].split("-").collect();
                    let range_two_parts: Vec<&str> = ranges[1].split("-").collect();

                    let range_one_start: u32 =
                        range_one_parts[0].parse().map_err(invalid_data_map)?;
                    let range_one_end: u32 =
                        range_one_parts[1].parse().map_err(invalid_data_map)?;

                    let range_two_start: u32 =
                        range_two_parts[0].parse().map_err(invalid_data_map)?;
                    let range_two_end: u32 =
                        range_two_parts[1].parse().map_err(invalid_data_map)?;

                    let range_one = range_one_start..range_one_end+1;
                    let range_two = range_two_start..range_two_end+1;

                    let field_test = field_test_fn(range_one, range_two);
                    field_tests.insert(fn_name, field_test);
                }
                ParseMode::MyTicket => {
                    for part in line_string.split(",") {
                        let part_u32: u32 = part.parse().map_err(invalid_data_map)?;
                        my_ticket.push(part_u32);
                    }
                }
                ParseMode::OtherTicket => {
                    let mut ticket = Vec::with_capacity(20);
                    for part in line_string.split(",") {
                        let part_u32: u32 = part.parse().map_err(invalid_data_map)?;
                        ticket.push(part_u32);
                    }
                    nearby_tickets.push(ticket);
                }
            }
        }
        Ok(Input { field_tests, my_ticket, nearby_tickets })
    }

    pub fn get_invalid_fields(&self) -> Vec<InvalidField> {
        let mut invalid_fields = Vec::new();

        for (ticket_no, ticket) in self.nearby_tickets.iter().enumerate() {
            'field: for (field_no, field) in ticket.iter().enumerate() {
                for test in self.field_tests.values() {
                    if test(field) {
                        continue 'field;
                    }
                }

                invalid_fields.push(InvalidField {
                    ticket_no,
                    field_no,
                    value: *field,
                })
            }
        }
        invalid_fields
    }
}
