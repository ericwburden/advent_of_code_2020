use crate::manifest::Action;
use std::convert::TryInto;

#[derive(Clone, Copy, Debug)]
pub enum Direction {
    North,
    South,
    East,
    West,
}

pub enum Rotation {
    CounterClockwise,
    Clockwise,
}

pub mod shipv1 {
    use super::{Action, Direction, Rotation, TryInto};

    #[derive(Debug)]
    pub struct Ship {
        heading: Direction,
        pos_x: i32,
        pos_y: i32,
    }

    impl Ship {
        pub fn new() -> Self {
            Ship {
                heading: Direction::East,
                pos_x: 0,
                pos_y: 0,
            }
        }

        pub fn take_action(&mut self, action: &Action) {
            match action {
                Action::North(x) => self.pos_y -= x,
                Action::South(x) => self.pos_y += x,
                Action::East(x) => self.pos_x += x,
                Action::West(x) => self.pos_x -= x,
                Action::Left(x) => self.tack(Rotation::CounterClockwise, *x),
                Action::Right(x) => self.tack(Rotation::Clockwise, *x),
                Action::Forward(x) => self.move_forward(*x),
            };
        }

        pub fn distance_from_origin(&self) -> u32 {
            (self.pos_x.abs() + self.pos_y.abs()).try_into().unwrap()
        }

        fn tack(&mut self, rotation: Rotation, mag: i32) {
            if mag == 0 {
                return;
            }
            let di = match self.heading {
                Direction::West => 0,
                Direction::North => 1,
                Direction::East => 2,
                Direction::South => 3,
            };
            let shift = match rotation {
                Rotation::CounterClockwise => -1 * (mag / 90),
                Rotation::Clockwise => 1 * (mag / 90),
            };
            let di = (di + shift).rem_euclid(4);

            self.heading = match di {
                0 => Direction::West,
                1 => Direction::North,
                2 => Direction::East,
                3 => Direction::South,
                _ => panic!("Attempted to index direction with {}", di),
            }
        }

        fn move_forward(&mut self, amount: i32) {
            match self.heading {
                Direction::West => self.pos_x -= amount,
                Direction::East => self.pos_x += amount,
                Direction::North => self.pos_y -= amount,
                Direction::South => self.pos_y += amount,
            }
        }
    }
}

pub mod shipv2 {
    use super::{Action, Rotation, TryInto};

    #[derive(Debug)]
    pub struct Waypoint {
        pos_x: i32,
        pos_y: i32,
    }

    #[derive(Debug)]
    pub struct Ship {
        pos_x: i32,
        pos_y: i32,
        waypoint: Waypoint,
    }

    impl Ship {
        #[rustfmt::skip]
        pub fn new() -> Self {
            let waypoint = Waypoint { pos_x: 10, pos_y: -1 };
            Ship { pos_x: 0, pos_y: 0, waypoint }
        }

        pub fn take_action(&mut self, action: &Action) {
            match action {
                Action::North(x) => self.waypoint.pos_y -= x,
                Action::South(x) => self.waypoint.pos_y += x,
                Action::East(x) => self.waypoint.pos_x += x,
                Action::West(x) => self.waypoint.pos_x -= x,
                Action::Left(x) => self.tack(Rotation::CounterClockwise, *x),
                Action::Right(x) => self.tack(Rotation::Clockwise, *x),
                Action::Forward(x) => self.move_forward(*x),
            };
        }

        pub fn distance_from_origin(&self) -> u32 {
            (self.pos_x.abs() + self.pos_y.abs()).try_into().unwrap()
        }

        fn tack(&mut self, rotation: Rotation, mag: i32) {
            let rotation_sign = match rotation {
                Rotation::CounterClockwise => -1,
                Rotation::Clockwise => 1,
            };
            let rotation_mag = mag.rem_euclid(360);
            let old_pos_x = self.waypoint.pos_x;
            let old_pos_y = self.waypoint.pos_y;
            match rotation_mag {
                0 => return,
                90 => {
                    self.waypoint.pos_x = old_pos_y * -rotation_sign;
                    self.waypoint.pos_y = old_pos_x * rotation_sign;
                }
                180 => {
                    self.waypoint.pos_x = -old_pos_x;
                    self.waypoint.pos_y = -old_pos_y;
                }
                270 => {
                    self.waypoint.pos_x = old_pos_y * rotation_sign;
                    self.waypoint.pos_y = old_pos_x * -rotation_sign;
                }
                _ => panic!("Invalid rotation magnitude {}", mag),
            }
        }

        fn move_forward(&mut self, times: i32) {
            for _ in 0..times {
                self.pos_x += self.waypoint.pos_x;
                self.pos_y += self.waypoint.pos_y;
            }
        }
    }
}
