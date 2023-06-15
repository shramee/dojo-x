///////////
// Tests //
///////////
mod tests {
    use core::traits::Into;
    use array::ArrayTrait;
    use dojo_core::auth::systems::{Route, RouteTrait};
    use dojo_core::{interfaces::IWorldDispatcherTrait, test_utils::spawn_test_world};
    use dojo_autonomous_agents::components::{
        PosComponent, VelComponent, AccComponent, ColorComponent, ZERO, val_from_2xpc
    };
    use dojo_autonomous_agents::systems::{Spawn, Update};
    use debug::PrintTrait;


    #[test]
    #[available_gas(30000000)]
    fn test_physics_update() {
        let caller = starknet::contract_address_const::<0x0>();

        // components
        let mut components = array::ArrayTrait::new();
        components.append(PosComponent::TEST_CLASS_HASH);
        components.append(VelComponent::TEST_CLASS_HASH);
        components.append(AccComponent::TEST_CLASS_HASH);
        components.append(ColorComponent::TEST_CLASS_HASH);
        // systems
        let mut systems = array::ArrayTrait::new();
        systems.append(Spawn::TEST_CLASS_HASH);
        systems.append(Update::TEST_CLASS_HASH);
        // routes
        let mut routes = array::ArrayTrait::new();
        // deploy executor, world and register components/systems
        let world = spawn_test_world(components, systems, routes);

        let mut systems = array::ArrayTrait::new();
        systems.append('Spawn');
        systems.append('Update');
        world.assume_role('sudo', systems);

        let spawn_call_data = array::ArrayTrait::new();
        world.execute('Spawn', spawn_call_data.span());

        let position = world.entity('Pos', 'mover'.into(), 0, 0);
        assert(*position[0] == ZERO.into(), 'pos1: x is wrong');
        assert(*position[1] == ZERO.into(), 'pos1: y is wrong');

        let mut update_calldata = array::ArrayTrait::new();
        world.execute('Update', update_calldata.span());

        let new_position = world.entity('Pos', 'mover'.into(), 0, 0);
        assert(*new_position[0] == val_from_2xpc(103).into(), 'pos2: x is wrong');
        assert(*new_position[1] == val_from_2xpc(102).into(), 'pos2: y is wrong');

        let mut update_calldata = array::ArrayTrait::new();
        world.execute('Update', update_calldata.span());
        let new_position = world.entity('Pos', 'mover'.into(), 0, 0);
    // assert(*new_position[0] == val_from_2xpc(106).into(), 'pos3: x is wrong');
    // assert(*new_position[1] == val_from_2xpc(104).into(), 'pos3: y is wrong');
    }
}
