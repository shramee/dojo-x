use array::ArrayTrait;

#[derive(Component, Copy, Drop, Serde)]
struct Color {
    v: (u8, u8, u8), 
}

#[derive(Component, Copy, Drop, Serde)]
// #[component(indexed = true)]
struct Pos {
    x: u32,
    y: u32,
}

#[derive(Component, Copy, Drop, Serde)]
// #[component(indexed = true)]
struct Vel {
    x: u32,
    y: u32,
}

#[derive(Component, Copy, Drop, Serde)]
// #[component(indexed = true)]
struct Acc {
    x: u32,
    y: u32,
}
