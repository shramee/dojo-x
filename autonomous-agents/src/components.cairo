use array::ArrayTrait;
use debug::PrintTrait;

// This is also half the world size
// Adjust math for this!
const ZERO: u32 = 50000;

// Converts percentage * 100 into a ZERO based value
// 100 is center of the map
// 50 is left/top half center of the map
// 200 is right/bottom most point on the map
fn val_from_2xpc(pc2x: u32) -> u32 {
    (ZERO * pc2x / 100)
}

#[derive(Component, Copy, Drop, Serde)]
struct Color {
    v: u32, 
}

#[derive(Component, Copy, Drop, Serde)]
#[component(indexed = true)]
struct Pos {
    x: u32,
    y: u32,
}

#[derive(Component, Copy, Drop, Serde)]
#[component(indexed = true)]
struct Vel {
    x: u32,
    y: u32,
}

#[derive(Component, Copy, Drop, Serde)]
#[component(indexed = true)]
struct Acc {
    x: u32,
    y: u32,
}
