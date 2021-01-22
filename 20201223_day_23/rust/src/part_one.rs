pub fn solve() {
    let cups: [usize; 9] = [1, 9, 8, 7, 5, 3, 4, 6, 2];
    let mut next_i: [usize; 9] = [0; 9];
    for i in 1..cups.len() {
        next_i[i - 1] = i;
    }

    let mut val_map: [usize; 9] = [0; 9];
    for i in 1..=9 {
        val_map[i - 1] = cups.iter().position(|x| *x == i).unwrap();
    }

    let max_cup = *cups.iter().max().unwrap();
    let mut current_i = 0;
    let mut destination_i;
    let mut destination_value;
    let mut picked_up_i: [usize; 3];

    for _ in 0..100 {
        picked_up_i = [
            next_i[current_i],
            next_i[next_i[current_i]],
            next_i[next_i[next_i[current_i]]],
        ];

        next_i[current_i] = next_i[picked_up_i[2]];

        destination_value = cups[current_i];
        let invalid_values = [
            destination_value,
            cups[picked_up_i[0]],
            cups[picked_up_i[1]],
            cups[picked_up_i[2]],
        ];
        while invalid_values.contains(&destination_value) {
            destination_value = if destination_value == 1 {
                max_cup
            } else {
                destination_value - 1
            }
        }
        destination_i = val_map[destination_value - 1];

        next_i[picked_up_i[2]] = next_i[destination_i];
        next_i[destination_i] = picked_up_i[0];

        current_i = next_i[current_i];
    }

    let mut current_cup = 1;
    let mut cups_in_order = Vec::with_capacity(9);
    let mut next_cup;

    for _ in 1..=8 {
        next_cup = cups[next_i[val_map[current_cup - 1]]];
        cups_in_order.push(next_cup);
        current_cup = next_cup;
    }

    println!("\nThe answer to part one is {:?}", cups_in_order);
}
