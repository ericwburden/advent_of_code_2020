use crate::bus_schedule::BusSchedule;

pub fn solve(bus_schedule: &BusSchedule) {
    let mut departure_times = Vec::new();
    let desired_time = bus_schedule.timestamp;
    for bus in &bus_schedule.buses {
        if let Some(x) = bus {
            let whole_intervals = (desired_time + (x - 1)) / x;
            let departure_time = whole_intervals * x;
            departure_times.push((*x, departure_time));
        }
    }
    let next_departure = departure_times
        .iter()
        .fold((usize::MAX, usize::MAX), |min, next| {
            if next.1 < min.1 {
                *next
            } else {
                min
            }
        });
    let wait_minutes = next_departure.1 - desired_time;
    let answer = next_departure.0 * wait_minutes;
    println!("\nThe answer to part one is {}", answer)
}
