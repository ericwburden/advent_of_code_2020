pub fn solve() {
    let mut cups = Vec::with_capacity(1_000_000);
    for n in &[1, 9, 8, 7, 5, 3, 4, 6, 2] {
        cups.push(*n);
    }
    for n in 10..=1_000_000 {
        cups.push(n);
    }

    let mut next_i = Vec::with_capacity(1_000_000);
    for i in 1..cups.len() {
        next_i.push(i);
    }
    next_i.push(0);

    let mut val_map = Vec::with_capacity(1_000_000);
    for i in 1..=9 {
        val_map.push(cups.iter().position(|x| *x == i).unwrap());
    }
    for i in 9..1_000_000 {
        val_map.push(i);
    }

    let max_cup = cups.len();
    let mut current_i = 0;
    let mut destination_i;
    let mut destination_value;
    let mut picked_up_i: [usize; 3];

    for _ in 1..=10_000_000 {
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

    let next_one = cups[next_i[val_map[0]]];
    let next_two = cups[next_i[val_map[next_one - 1]]];

    println!("\nThe answer to part two is {:?}", next_one * next_two);

    //next_one: 65969
    //next_two: 968217
    //The answer to part two is 63872307273
}
