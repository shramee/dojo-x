use array::ArrayTrait;
use debug::PrintTrait;

// This is also the world size
// Adjust math for this!
const ZERO: u32 = 1000000;
const RANGE: u32 = 20000;

// Converts percentage * 100 into a ZERO based value
// 100 is center of the map
// 50 is left/top half center of the map
// 200 is right/bottom most point on the map
fn val_from_2xpc(pc2x: u32) -> u32 {
    let half_range = RANGE / 2;
    ZERO - half_range + (half_range * pc2x) / 100
}

#[test]
#[available_gas(2000000)]
fn test_map_bounds() {
    let min = val_from_2xpc(0);
    let v_center = val_from_2xpc(100);
    let max = val_from_2xpc(200);
    assert(max - min == RANGE, 'map_bounds: min and max');
    assert(v_center == ZERO, 'map_bounds: 100 should be 0')
}

#[derive(Copy, Drop, Serde)]
struct Vec2 {
    x: u32,
    y: u32,
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
