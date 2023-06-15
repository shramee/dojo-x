#[system]
mod Spawn {
    use array::ArrayTrait;
    use traits::{Into, TryInto};
    use starknet::contract_address_try_from_felt252;

    use dojo_autonomous_agents::components::{Pos, Color};

    fn execute(ctx: Context) {
        commands::set_entity(
            contract_address_try_from_felt252('mover').unwrap().into(),
            (Pos(0, 0), Vel(0, 0, ), Acc(0, 0, ))
        );
        commands::set_entity(
            contract_address_try_from_felt252('seeker').unwrap().into(),
            (Pos(0, 0), Vel(0, 0, ), Acc(0, 0, ))
        );
        return ();
    }
}

#[system]
mod Update {
    use array::ArrayTrait;
    use traits::Into;

    use dojo_autonomous_agents::components::{Pos, Vel, Acc};

    fn execute(ctx: Context) {
        let (p, v, a) = commands::<Pos, Vel, Acc>::entity(ctx.caller_account.into());
        let uh = commands::set_entity(
            ctx.caller_account.into(),
            (
                Pos {
                    x: p.x + v.x, y: p.y + v.y
                    }, // Pos += Vel
                     Vel {
                    x: v.x + a.x, y: v.y + a.y
                    }, // Vel += Acc
                     Acc {
                    x: 0, y: 0
                }, // Acc reset
                 color,
            )
        );
        return ();
    }
}
mod tests {
    use core::traits::Into;
    use array::ArrayTrait;

    use dojo_core::auth::systems::{Route, RouteTrait};
    use dojo_core::interfaces::IWorldDispatcherTrait;
    use dojo_core::test_utils::spawn_test_world;

    use dojo_autonomous_agents::components::{
        PosComponent, VelComponent, AccComponent, ColorComponent
    };
    use dojo_autonomous_agents::systems::{Spawn, Update};

    #[test]
    #[available_gas(30000000)]
    fn test_physics_update() {
        let caller = starknet::contract_address_const::<0x1337>();
        starknet::testing::set_account_contract_address(caller);

        // components
        let mut components = array::ArrayTrait::new();
        components.append(PosComponent::TEST_CLASS_HASH);
        components.append(ColorComponent::TEST_CLASS_HASH);
        // systems
        let mut systems = array::ArrayTrait::new();
        systems.append(Spawn::TEST_CLASS_HASH);
        systems.append(Update::TEST_CLASS_HASH);
        // routes
        let mut routes = array::ArrayTrait::new();
        routes
            .append(
                RouteTrait::new(
                    'Update'.into(), // target_id
                    'MovesWriter'.into(), // role_id
                    'Color'.into(), // resource_id
                )
            );
        routes
            .append(
                RouteTrait::new(
                    'Update'.into(), // target_id
                    'PositionWriter'.into(), // role_id
                    'Pos'.into(), // resource_id
                )
            );
        routes
            .append(
                RouteTrait::new(
                    'Spawn'.into(), // target_id
                    'MovesWriter'.into(), // role_id
                    'Color'.into(), // resource_id
                )
            );
        routes
            .append(
                RouteTrait::new(
                    'Spawn'.into(), // target_id
                    'PositionWriter'.into(), // role_id
                    'Pos'.into(), // resource_id
                )
            );

        // deploy executor, world and register components/systems
        let world = spawn_test_world(components, systems, routes);

        let spawn_call_data = array::ArrayTrait::new();
        world.execute('Spawn'.into(), spawn_call_data.span());

        let mut move_calldata = array::ArrayTrait::new();
        // move_calldata.append(Update::Direction::Right(()).into());
        world.execute('Update'.into(), move_calldata.span());

        let moves = world.entity('Color'.into(), caller.into(), 0, 0);
        assert(*moves[0] == 9, 'moves is wrong');
    // let new_position = world.entity('Pos'.into(), caller.into(), 0, 0);
    // assert(*new_position[0] == 1, 'position x is wrong');
    // assert(*new_position[1] == 0, 'position y is wrong');
    }
}

