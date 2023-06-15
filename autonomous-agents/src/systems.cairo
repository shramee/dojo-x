use dojo_core::storage::query::{Query, QueryTrait};

#[system]
mod Spawn {
    use traits::Into;
    use array::ArrayTrait;
    use dojo_autonomous_agents::components::{Pos, Vel, Acc};

    fn execute(ctx: Context) {
        commands::set_entity('mover'.into(), (Acc { x: 0, y: 0 }, Pos { x: 0, y: 0 }, Vel { x: 0, y: 0 }));
        commands::set_entity('seeker'.into(), (Acc { x: 0, y: 0 }, Pos { x: 0, y: 0 }, Vel { x: 0, y: 0 }));
        return ();
    }
}

#[system]
mod Update {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_autonomous_agents::components::{Pos, Vel, Acc};

    fn execute(ctx: Context) {
        let p = commands::<Pos>::entity('mover'.into());
        let (v, a) = commands::<(Vel, Acc)>::entity('mover'.into());
        let uh = commands::set_entity('mover'.into(), (Acc { x: 0, y: 0  }, Pos { x: p.x + v.x, y: p.y + v.y  }, Vel { x: v.x + a.x, y: v.y + a.y  }, ));
        return ();
    }
}

mod tests {
    // use dojo_core::storage::query::QueryTrait;
    use core::traits::Into;
    use array::ArrayTrait;
    use dojo_core::auth::systems::{Route, RouteTrait};
    use dojo_core::{interfaces::IWorldDispatcherTrait, test_utils::spawn_test_world};
    use dojo_autonomous_agents::components::{
        PosComponent, VelComponent, AccComponent, ColorComponent
    };
    use dojo_autonomous_agents::systems::{Spawn, Update};

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
        assert(*position[0] == 0, 'position x is wrong');
        assert(*position[1] == 0, 'position y is wrong');

        let mut update_calldata = array::ArrayTrait::new();
        world.execute('Update', update_calldata.span());
        // let new_position = world.entity('Pos', 'mover'.into(), 0, 2);
        // assert(*new_position[0] == 1, 'position x is wrong');
        // assert(*new_position[1] == 0, 'position y is wrong');
    }
}
