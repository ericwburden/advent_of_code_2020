use crate::input::{Input, InvalidField};
use std::collections::{HashMap, HashSet};

pub fn solve(input: &Input, invalid_fields: &Vec<InvalidField>) {
    let mut invalid_ticket_nos = HashSet::new();
    for entry in invalid_fields {
        invalid_ticket_nos.insert(entry.ticket_no);
    }

    let mut valid_tickets = Vec::new();
    for (i, ticket) in input.nearby_tickets.iter().enumerate() {
        if !invalid_ticket_nos.contains(&i) {
            valid_tickets.push(ticket);
        }
    }

    let ticket_len = input.my_ticket.len();
    let mut field_matches: HashMap<String, Vec<usize>> = HashMap::new();
    for (test_name, test) in input.field_tests.iter() {
        'fields: for field_no in 0..ticket_len {
            for ticket in valid_tickets.iter() {
                if !test(&ticket[field_no]) {
                    continue 'fields;
                }
            }
            let test_name_str = test_name.to_string();
            field_matches
                .entry(test_name_str)
                .or_insert(Vec::new())
                .push(field_no);
        }
    }

    let mut sorted_field_names = vec![""; ticket_len];
    for (name, val) in field_matches.iter() {
        sorted_field_names[val.len() - 1] = name;
    }

    let mut confirmed_field_nos: Vec<usize> = Vec::new();
    let mut confirmed_fields = HashMap::new();
    for field_name in sorted_field_names {
        let possible_field_nos = field_matches.get(field_name).unwrap();
        let remaining_field_no: Vec<usize> = possible_field_nos
            .iter()
            .filter(|x| !confirmed_field_nos.contains(x))
            .map(|x| *x)
            .collect();
        confirmed_field_nos.extend(&remaining_field_no);
        confirmed_fields.insert(field_name.to_string(), remaining_field_no[0]);
    }

    let mut answer: u64 = 1;
    for (field_name, field_no) in confirmed_fields.iter() {
        if field_name.contains("departure") {
            answer *= input.my_ticket[*field_no] as u64;
        }
    }

    println!("\nThe answer to part two is {}", answer);
}
