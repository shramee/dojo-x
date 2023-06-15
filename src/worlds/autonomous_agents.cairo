use core::traits::Into;
use super::utils_physics::{Vec2, Vec2Trait};
// This is the world contract
#[contract]
mod AutonomousAgents {
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
        velocityIndex: LegacyMap<usize, felt252>,
        velocityCount: usize,
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
                velocityCount::write(count + 1);
            },
            Components::velocity(v) => {
                let count = velocityCount::read();
                velocityIndex::write(count, entity_id);
                velocityCount::write(count + 1);
            },
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

    // Add component to entity
    fn get_indexed_entities(component: Components) {
        match component {
            Components::position(_) => {
                let count = positionCount::read();
                positionIndex::write(count, entity_id);
                velocityCount::write(count + 1);
            },
            Components::velocity(_) => {
                let count = velocityCount::read();
                velocityIndex::write(count, entity_id);
                velocityCount::write(count + 1);
            },
            Components::max_velocity(_) => {},
            Components::acceleration(_) => {},
        }
        maybe_index_entity_component(entity_id, component);
    }

    // Constructor
    #[constructor]
    fn constructor(owner_: ContractAddress) {
        owner::write(owner_);
        init();
    }

    fn spawn_bundle(entity_id: felt252, position: Vec2) {
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

    #[view]
    fn entity_positions() -> felt252 {}
}

fn test_util_get_entity_physics(entity_id: felt252) -> (Vec2, Vec2, Vec2) {
    (
        AutonomousAgents::position::read(entity_id),
        AutonomousAgents::velocity::read(entity_id),
        AutonomousAgents::acceleration::read(entity_id),
    )
}

#[test]
#[available_gas(2000000)]
fn test_spawn() {
    AutonomousAgents::spawn_bundle('ent1', Vec2Trait::new(5, 7));

    let (p, v, a) = test_util_get_entity_physics('ent1');

    assert(p.x == 5, 'pos x is incorrect');
    assert(v.x == 0, 'vel x is incorrect');
    assert(a.x == 0, 'acc x is incorrect');

    assert(p.y == 7, 'pos y is incorrect');
    assert(v.y == 0, 'vel y is incorrect');
    assert(a.y == 0, 'acc y is incorrect');
}

#[test]
#[available_gas(2000000)]
fn test_update_world() {
    AutonomousAgents::spawn_bundle('e', Vec2Trait::new(5, 7));

    // Add velocity and test position update
    AutonomousAgents::velocity::write('e', Vec2Trait::new(2, 1));
    AutonomousAgents::update();

    let (p, v, a) = test_util_get_entity_physics('e');
    assert(p.x == 7, 'vel: pos x incorrect');
    assert(p.y == 8, 'vel: pos y incorrect');

    // Add acceleration and test position update
    let a_apply = Vec2Trait::new(3, 4);
    AutonomousAgents::accelerate_entity('e', a_apply);
    AutonomousAgents::update();
    let (p2, v2, a2) = test_util_get_entity_physics('e');
    assert(a2.x == 0, 'acc x not reset');
    assert(a2.y == 0, 'acc y not reset');

    assert(v2.x - v.x == a_apply.x, 'acc: vel x incorrect');
    assert(v2.y - v.y == a_apply.y, 'acc: vel y incorrect');

    assert(p2.x - p.x == 5, 'acc: pos x incorrect');
    assert(p2.y - p.y == 7, 'acc: pos y incorrect');
}
