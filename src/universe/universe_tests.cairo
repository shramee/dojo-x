use core::option::OptionTrait;
use core::array::ArrayTrait;
use core::traits::TryInto;
use super::base::Universe;
use starknet::{ContractAddress, contract_address_const};
use starknet::testing::set_caller_address;
use box::BoxTrait;

#[test]
#[available_gas(1000000000)]
fn test_get_worlds() {
    Universe::register_world('world1', contract_address_const::<0xea814>());
    let worlds = Universe::get_worlds();

    assert(*worlds.get(0).unwrap().unbox().id == 'world1', 'Array incorrect');
    assert(worlds.len() == 1, 'Array incorrect');
}

#[test]
#[available_gas(1000000000)]
#[should_panic]
fn test_duplicate_worlds() {
    Universe::register_world('world1', contract_address_const::<0xea8140>());
    Universe::register_world('world2', contract_address_const::<0xea8141>());
    Universe::register_world('world1', contract_address_const::<0xea8142>());
}

#[test]
#[available_gas(1000000000)]
fn test_player_move_to_world() {
    // Add some worlds
    Universe::register_world('world1', contract_address_const::<0xea8140>());
    Universe::register_world('world2', contract_address_const::<0xea8141>());

    // Move some players to the created worlds.
    let caller = contract_address_const::<0xb0b>();
    set_caller_address(caller);
    Universe::move_to_world('world1');
    assert(Universe::get_player_world() == 'world1', 'Array incorrect');
    let caller = contract_address_const::<0xb01>();
    set_caller_address(caller);
    Universe::move_to_world('world2');
    assert(Universe::get_player_world() == 'world2', 'Array incorrect');
}

