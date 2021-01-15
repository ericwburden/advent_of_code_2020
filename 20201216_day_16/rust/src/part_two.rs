use crate::input::{Input, InvalidField};
use std::collections::{HashMap, HashSet};

pub fn solve(input: &Input, invalid_fields: &Vec<InvalidField>) {
    let mut invalid_ticket_nos = HashSet::new();
    for entry in invalid_fields {
        invalid_ticket_nos.insert(entry.ticket_no);
    }

    // Get a Vec of the neighboring tickets that contained only valid fields
    let mut valid_tickets = Vec::new();
    for (i, ticket) in input.nearby_tickets.iter().enumerate() {
        if !invalid_ticket_nos.contains(&i) {
            valid_tickets.push(ticket);
        }
    }

    // Build up a HashMap where the key is the name of each field and the value is a Vec containing
    // the field indices for each field where the values at that index all satisfied the range
    // requirements for that given field. For example, if the values at indices 3, 7, and 9 all
    // satisified the range test for field "zone", then there would be an entry "zone": [3, 7, 9].
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

    // It is observed that, in `field_matches` that there is exactly one entry with a value of
    // length 1, one entry with a value length 2, one entry with a value length 3, etc. This means
    // two things: (1) the entries in 'field_matches' can be sorted by value length and (2) we
    // can conclude that the 'field_name' for the first entry *must* match the field index of that
    // length 1 result and that index can be ignored in subsequent fields. For example, if we have
    // entries "seat": [10] and "zone": [10, 5], then field 10 must be "seat" and field 5 must be
    // "zone", and so on.
    // This bit produces a Vec of field names, sorted by length of the values in 'field_matches'
    let mut sorted_field_names = vec![""; ticket_len];
    for (name, val) in field_matches.iter() {
        sorted_field_names[val.len() - 1] = name;
    }

    // For each field name in `sorted_field_names`, identifies the index in entry values that is
    // not already confirmed for another field. By proceding in length order, it is guaranteed to
    // always be a single index for this problem set
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

    // Multiply together all the values from 'my ticket' where the indices matched the confirmed
    // indices for a field beginning with the word 'departure'
    let mut answer: u64 = 1;
    for (field_name, field_no) in confirmed_fields.iter() {
        if field_name.contains("departure") {
            answer *= input.my_ticket[*field_no] as u64;
        }
    }

    println!("\nThe answer to part two is {}", answer);
}
