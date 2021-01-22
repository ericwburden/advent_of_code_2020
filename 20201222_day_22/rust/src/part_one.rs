use std::collections::VecDeque;

pub fn solve(player1: &mut VecDeque<u16>, player2: &mut VecDeque<u16>) {
    while player1.len() > 0 && player2.len() > 0 {
        let player1_card = player1.pop_front().unwrap();
        let player2_card = player2.pop_front().unwrap();

        if player1_card > player2_card {
            player1.push_back(player1_card);
            player1.push_back(player2_card);
        } else {
            player2.push_back(player2_card);
            player2.push_back(player1_card);
        }
    }

    let winning_hand = if player1.len() > 0 { player1 } else { player2 };

    let answer = winning_hand
        .iter()
        .zip((1..=50).rev())
        .fold(0usize, |t, (a, b)| t + (*a as usize * b));

    println!("\nThe answer to part one is {:#?}", answer);
}
