use std::collections::HashSet;
use std::collections::VecDeque;

#[derive(Debug, PartialEq)]
enum Winner {
    PlayerOne,
    PlayerTwo,
    Undecided,
}

#[rustfmt::skip]
fn play_round(
    p1: &mut VecDeque<u16>,
    p2: &mut VecDeque<u16>,
    states: &mut HashSet<Vec<(u16, u16)>>,
) -> Winner {
    let current_state: Vec<_> = p1
        .iter()
        .map(|x| *x)
        .zip(p2.iter().map(|x| *x))
        .collect();

    if !states.insert(current_state) { return Winner::PlayerOne; }

    let p1_card = p1.pop_front().unwrap();
    let p2_card = p2.pop_front().unwrap();

    let hand_winner = if p1_card as usize > p1.len() || p2_card as usize > p2.len() {
        if p1_card > p2_card { Winner::PlayerOne } else { Winner::PlayerTwo }
    } else {
        let p1_max = p1.iter()
            .enumerate()
            .filter(|(i, _)| i < &(p1_card as usize))
            .fold(0, |m, n| if n.1 > &m { *n.1 } else { m });
        let p2_max = p2.iter()
            .enumerate()
            .filter(|(i, _)| i < &(p2_card as usize))
            .fold(0, |m, n| if n.1 > &m { *n.1 } else { m });

        if p1_max > p2_max {
            Winner::PlayerOne
        } else {
            let p1_vec: Vec<_> = p1.iter()
                .enumerate()
                .filter(|(i, _)| i < &(p1_card as usize))
                .map(|(_, v)| *v)
                .collect();
            let mut p1_sub = VecDeque::from(p1_vec);

            let p2_vec: Vec<_> = p2.iter()
                .enumerate()
                .filter(|(i, _)| i < &(p2_card as usize))
                .map(|(_, v)| *v)
                .collect();
            let mut p2_sub = VecDeque::from(p2_vec);

            let mut states = HashSet::with_capacity(1000);
            while let Winner::Undecided = play_round(&mut p1_sub, &mut p2_sub, &mut states) {}
            if p1_sub.len() > 0 { Winner::PlayerOne } else { Winner::PlayerTwo }
        }
    };

    if hand_winner == Winner::PlayerOne {
        p1.push_back(p1_card);
        p1.push_back(p2_card);
    } else {
        p2.push_back(p2_card);
        p2.push_back(p1_card);
    }

    if p1.len() == 0 { return Winner::PlayerTwo; } 
    if p2.len() == 0 { return Winner::PlayerOne; }
    Winner::Undecided
}

pub fn solve(p1: &mut VecDeque<u16>, p2: &mut VecDeque<u16>) {
    let mut past_states = HashSet::with_capacity(1000);

    while let Winner::Undecided = play_round(p1, p2, &mut past_states) {}

    let winning_hand = if p1.len() > 0 { &p1 } else { &p2 };

    let answer = winning_hand
        .iter()
        .zip((1..=winning_hand.len()).rev())
        .fold(0, |t, (a, b)| t + (*a as usize * b));

    println!("\nThe answer to part two is {:#?}", answer);
}
