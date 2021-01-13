use crate::bus_schedule::BusSchedule;

pub fn solve(bus_schedule: &BusSchedule) {
    let buses = &bus_schedule.buses;
    let mut offset = 0;
    let mut interval = buses[0].unwrap();
    let mut timestamp = interval;

    for maybe_bus in &buses[1..] {
        offset += 1;
        let bus = match maybe_bus {
            None => continue,
            Some(x) => x,
        };
        loop {
            timestamp += interval;
            if (timestamp + offset) % bus == 0 {
                interval *= bus;
                break;
            }
        }
    }

    println!("\nThe answer to part two is {}", timestamp);
}
