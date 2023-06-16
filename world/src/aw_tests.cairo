use core::traits::Into;
use world::utils_physics::{Vec2, Vec2Trait, val_from_2xpc};
use world::aw_contract::World;

// 
fn test_util_get_entity_physics(entity_id: felt252) -> (Vec2, Vec2, Vec2) {
    (
        World::position::read(entity_id),
        World::velocity::read(entity_id),
        World::acceleration::read(entity_id),
    )
}

#[test]
#[available_gas(2000000)]
fn test_spawn() {
    World::spawn_bundle('ent1', Vec2Trait::new(5, 7), Vec2Trait::zero());

    let (p, v, a) = test_util_get_entity_physics('ent1');

    assert(p.x == val_from_2xpc(5), 'pos x is incorrect');
    assert(v.x == val_from_2xpc(0), 'vel x is incorrect');
    assert(a.x == val_from_2xpc(0), 'acc x is incorrect');

    assert(p.y == val_from_2xpc(7), 'pos y is incorrect');
    assert(v.y == val_from_2xpc(0), 'vel y is incorrect');
    assert(a.y == val_from_2xpc(0), 'acc y is incorrect');
}

#[test]
#[available_gas(2000000)]
fn test_update_world() {
    World::spawn_bundle('e', Vec2Trait::new(val_from_2xpc(5), val_from_2xpc(7)), Vec2Trait::zero());

    // Add velocity and test position update
    World::velocity::write('e', Vec2Trait::new(2, 1));
    World::update();

    let (p, v, a) = test_util_get_entity_physics('e');
    assert(p.x == val_from_2xpc(7), 'vel: pos x incorrect');
    assert(p.y == val_from_2xpc(8), 'vel: pos y incorrect');

    // // Add acceleration and test position update
    // let a_apply = Vec2Trait::new(3, 4);
    // World::accelerate_entity('e', a_apply);
    // World::update();
    // let (p2, v2, a2) = test_util_get_entity_physics('e');
    // assert(a2.x == 0, 'acc x not reset');
    // assert(a2.y == 0, 'acc y not reset');

    // assert(v2.x - v.x == a_apply.x, 'acc: vel x incorrect');
    // assert(v2.y - v.y == a_apply.y, 'acc: vel y incorrect');

    // assert(p2.x - p.x == 5, 'acc: pos x incorrect');
    // assert(p2.y - p.y == 7, 'acc: pos y incorrect');
}
