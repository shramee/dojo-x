use dojo_core::storage::query::{Query, QueryTrait};
fn felt_to_qry(f: felt252) -> Query {
    QueryTrait::new_from_id(f)
}

#[system]
mod Spawn {
    use traits::Into;
    use array::ArrayTrait;
    use dojo_autonomous_agents::components::{Pos, Vel, Acc};
    use super::felt_to_qry;

    fn execute(ctx: Context) {
        commands::set_entity(felt_to_qry('mover'), (Acc(0, 0), Pos(0, 0), Vel(0, 0)));
        commands::set_entity(felt_to_qry('seeker'), (Acc(0, 0), Pos(0, 0), Vel(0, 0)));
        return ();
    }
}

#[system]
mod Update {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_autonomous_agents::components::{Pos, Vel, Acc};
    use super::felt_to_qry;

    fn execute(ctx: Context) {
        // let (p, v, a) = commands::<Pos, Vel, Acc>::entity(felt_to_qry('mover'));
        let (p, v, a) = commands::<(Pos, Vel, Acc)>::entity(felt_to_qry('mover'));

        let p_ = Pos { x: p.x + v.x, y: p.y + v.y,  };
        let v_ = Vel { x: v.x + a.x, y: v.y + a.y,  };
        let a_ = Acc { x: 0, y: 0,  };
        let uh = commands::set_entity(felt_to_qry('mover'), (a_, p_, v_, ));
        return ();
    }
}
mod tests {
    // use dojo_core::storage::query::QueryTrait;
    use core::traits::Into;
    use array::ArrayTrait;
    use dojo_core::auth::systems::{Route, RouteTrait};
    use dojo_core::{interfaces::IWorldDispatcherTrait, test_utils::spawn_test_world};
    use super::felt_to_qry;
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

        let spawn_call_data = array::ArrayTrait::new();
        world.execute('Spawn'.into(), spawn_call_data.span());

        let mut update_calldata = array::ArrayTrait::new();
        world.execute('Update'.into(), update_calldata.span());
        let new_position = world.entity('Pos'.into(), felt_to_qry('mover'), 0, 0);
        assert(*new_position[0] == 1, 'position x is wrong');
        assert(*new_position[1] == 0, 'position y is wrong');
    }
}

