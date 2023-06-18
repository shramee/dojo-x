#[system]
mod Spawn {
    use traits::Into;
    use array::ArrayTrait;
    use dojo_autonomous_agents::components::{Color, Pos, Vel, Acc, ZERO, val_from_2xpc};

    fn execute(ctx: Context) {
        commands::set_entity(3.into(), (Color { v: 0xf50505 }));
        commands::set_entity(4.into(), (Color { v: 0x5f99f0 }));
        commands::set_entity(
            1.into(),
            (
                Acc {
                    x: val_from_2xpc(100), y: val_from_2xpc(100)
                    }, Pos {
                    x: ZERO, y: ZERO
                    }, Vel {
                    x: val_from_2xpc(103), y: val_from_2xpc(102)
                }
            )
        );
        commands::set_entity(
            2.into(), (Acc { x: ZERO, y: ZERO }, Pos { x: ZERO, y: ZERO }, Vel { x: ZERO, y: ZERO })
        );
        return ();
    }
}

#[system]
mod Update {
    use array::ArrayTrait;
    use traits::Into;
    use dojo_autonomous_agents::components::{Pos, Vel, Acc, Vec2, ZERO, val_from_2xpc};
    use debug::PrintTrait;

    // use dojo_core::storage::query::{QueryTrait};
    // Use while coding for autocomplete, but not when running/compiling
    // use dojo_core::interfaces::IWorldDispatcherTrait;
    // use dojo_core::execution_context::Context;

    fn vec_entity(ctx: Context, component: felt252, entity_id: felt252) -> Vec2 {
        let mut p = ctx.world.entity(component, entity_id.into(), 0_u8, 0_usize);
        serde::Serde::<Vec2>::deserialize(ref p).expect('missing data')
    }

    fn update_physics(ctx: Context, entity_id: felt252) -> (u32, u32, u32, u32, ) {
        let mut p = vec_entity(ctx, 'Pos', entity_id);
        let mut v = vec_entity(ctx, 'Vel', entity_id);
        let mut a = vec_entity(ctx, 'Acc', entity_id);

        p.x -= ZERO / 2;
        p.y -= ZERO / 2;
        v.x -= ZERO / 2;
        v.y -= ZERO / 2;
        a.x -= ZERO / 2;
        a.y -= ZERO / 2;

        p.x.print();
        p.y.print();
        v.x.print();
        v.y.print();
        a.x.print();
        a.y.print();

        // Add acceleration to velocity
        'Adding acc'.print();
        v.x += a.x;
        v.y += a.y;
        // Add velocity to position
        'Adding vel'.print();
        p.x += v.x - ZERO / 2;
        p.y += v.y - ZERO / 2;
        (p.x, p.y, v.x, v.y)
    }

    fn execute(ctx: Context) {
        let (mpx, mpy, mvx, mvy, ) = update_physics(ctx, 1);
        let (spx, spy, svx, svy, ) = update_physics(ctx, 2);

        commands::set_entity(
            1.into(), (Acc { x: ZERO, y: ZERO }, Pos { x: mpx, y: mpy }, Vel { x: mvx, y: mvy }, )
        );
        commands::set_entity(
            2.into(), (Acc { x: ZERO, y: ZERO }, Pos { x: spx, y: spy }, Vel { x: svx, y: svy }, )
        );
        return ();
    }
}
