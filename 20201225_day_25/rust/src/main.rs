use std::time::Instant;

fn main() {
    let start = Instant::now();
    let card_key = 3248366u64;
    let door_key = 4738476u64;

    let mut pub_key = 1;
    let mut encryption_key = 1;

    while pub_key != card_key {
        pub_key = (pub_key * 7u64) % 20201227u64;
        encryption_key = (encryption_key * door_key) % 20201227u64;
    }

    println!("\nThe answer is {}", encryption_key);
    println!("Solved in {:?}\n", start.elapsed());
}
