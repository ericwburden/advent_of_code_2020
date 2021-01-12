use crate::manifest::Manifest;
use crate::ship::shipv1::Ship;

pub fn solve(filename: &str) {
    let manifest = Manifest::from_file(filename).ok().unwrap();
    let mut ship = Ship::new();
    for action in manifest {
        ship.take_action(&action);
    }
    let answer = ship.distance_from_origin();
    println!("\nThe answer to part one is {}", answer);
}
