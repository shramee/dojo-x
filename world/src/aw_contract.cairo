use core::traits::Into;
use super::utils_physics::{Vec2, Vec2Trait};

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
        add_entity_component(entity_id, Components::velocity(Vec2Trait::zero()));
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
        apply_physics();
    }

    // Applies physics via update
    fn apply_physics() {}
}
