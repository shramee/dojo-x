use core::traits::Into;
use super::utils_physics::{Vec2, Vec2Trait, ZERO, RANGE, val_from_2xpc};

// This is the world contract
#[contract]
mod World {
    use super::super::utils_physics::{Vec2, Vec2Trait};
    use starknet::{ContractAddress, };

    struct Storage {
        // World properties
        owner: ContractAddress,
        // Components
        color: LegacyMap<felt252, u32>,
        shape: LegacyMap<felt252, Vec2>,
        position: LegacyMap<felt252, Vec2>,
        velocity: LegacyMap<felt252, Vec2>,
        max_velocity: LegacyMap<felt252, Vec2>,
        acceleration: LegacyMap<felt252, Vec2>,
        // Component indexes
        positionIndex: LegacyMap<usize, felt252>,
        positionCount: usize,
    }

    // Components enum for referring to components
    #[derive(Copy, Drop, Serde)]
    enum Components {
        position: Vec2,
        velocity: Vec2,
        max_velocity: Vec2,
        acceleration: Vec2,
    }

    // Add component to entity
    fn maybe_index_entity_component(entity_id: felt252, component: Components) {
        match component {
            Components::position(v) => {
                let count = positionCount::read();
                positionIndex::write(count, entity_id);
                positionCount::write(count + 1);
            },
            Components::velocity(v) => {},
            Components::max_velocity(v) => {},
            Components::acceleration(v) => {},
        }
    }

    // Add component to entity
    fn add_entity_component(entity_id: felt252, component: Components) {
        match component {
            Components::position(v) => {
                position::write(entity_id, v);
            },
            Components::velocity(v) => {
                velocity::write(entity_id, v);
            },
            Components::max_velocity(v) => {
                max_velocity::write(entity_id, v);
            },
            Components::acceleration(v) => {
                acceleration::write(entity_id, v);
            },
        }
        maybe_index_entity_component(entity_id, component);
    }

    // Constructor
    #[constructor]
    fn constructor(owner_: ContractAddress) {
        owner::write(owner_);
        init();
    }

    fn spawn_bundle(entity_id: felt252, position: Vec2, velocity: Vec2) {
        add_entity_component(entity_id, Components::position(position));
        add_entity_component(entity_id, Components::velocity(velocity));
        add_entity_component(entity_id, Components::acceleration(Vec2Trait::zero()));
    }

    fn accelerate_entity(entity_id: felt252, a: Vec2) {
        add_entity_component(entity_id, Components::acceleration(a));
    }

    // Stuff that needs to happen for setup
    fn init() { //
    //////////////////////////
    // @TODO Spawn entities //
    //////////////////////////
    }

    // Updates the world at regular intervals
    #[external]
    fn update() {
        apply_physics('mover');
        apply_physics('seeker');


    }

    // Applies physics via update
    fn apply_physics(entity_id: felt252) {
        let (mut p, mut v, mut a) = util_get_entity_physics(entity_id);

        // Add acceleration to velocity
        v.x += a.x - world::utils_physics::ZERO;
        v.y += a.y - world::utils_physics::ZERO;
        // Add velocity to position
        p.x += v.x - world::utils_physics::ZERO;
        p.y += v.y - world::utils_physics::ZERO;
        
        spawn_bundle(entity_id, p, v);
}

fn util_get_entity_physics(entity_id: felt252) -> (Vec2, Vec2, Vec2) {
    (
        position::read(entity_id),
        velocity::read(entity_id),
        acceleration::read(entity_id),
    )
    }
}
