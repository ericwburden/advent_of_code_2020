pub fn solve() {
    let starting_cups = [1, 9, 8, 7, 5, 3, 4, 6, 2];
    let mut first_next_cups = [0; 10];

    first_next_cups[0] = starting_cups[0];

    for i in 0..starting_cups.len() - 1 {
        first_next_cups[starting_cups[i] as usize] = starting_cups[i + 1];
    }

    first_next_cups[starting_cups[starting_cups.len() - 1] as usize] =
        (starting_cups.len() + 1) as u32;

    let mut cups: Vec<u32> = Vec::with_capacity(1_000_000 + 1);
    cups.extend(&first_next_cups);

    for i in 10..1_000_000 {
        cups.push(i + 1);
    }

    cups.push(starting_cups[0]);

    for _ in 0..10_000_000 {
        let max_cup = cups.len() - 1;
        let current_cup = cups[0];

        let wrap = |cup: u32| -> u32 { ((cup as usize + (max_cup - 1)) % max_cup + 1) as u32 };

        let next = |cup: u32| -> u32 {
            if cups[cup as usize] != 0 {
                cups[cup as usize]
            } else {
                wrap(cup + 1)
            }
        };

        let mut four_cups = [0; 4];
        let mut start = current_cup;

        for cup in &mut four_cups {
            start = next(start);
            *cup = start;
        }

        let mut destination_cup = wrap(current_cup - 1);

        while four_cups[0..3].contains(&destination_cup) {
            destination_cup = wrap(destination_cup - 1);
        }

        let next_after_destination = next(destination_cup);
        let [first, _, third, fourth] = four_cups;

        cups[0] = fourth;
        cups[current_cup as usize] = fourth;
        cups[destination_cup as usize] = first;
        cups[third as usize] = next_after_destination;
    }

    let first = cups[1];
    let second = cups[first as usize];

    println!("Two B: {}", first as u64 * second as u64);
}
