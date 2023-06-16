#[system]
mod Spawn {
    use traits::Into;
    use array::ArrayTrait;
    use dojo_autonomous_agents::components::{Color, Pos, Vel, Acc, ZERO, val_from_2xpc};

    fn execute(ctx: Context) {
        commands::set_entity('mover_color'.into(), (Color { v: 0xf50505 }));
        commands::set_entity('seeker_color'.into(), (Color { v: 0x5f99f0 }));
        commands::set_entity(
            'mover'.into(),
            (
                Acc {
                    x: ZERO, y: ZERO
                    }, Pos {
                    x: ZERO, y: ZERO
                    }, Vel {
                    x: val_from_2xpc(103), y: val_from_2xpc(102)
                }
            )
        );
        commands::set_entity(
            'seeker'.into(),
            (Acc { x: ZERO, y: ZERO }, Pos { x: ZERO, y: ZERO }, Vel { x: ZERO, y: ZERO })
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

    // fn phy_component_span(px: u32, py: u32, vx: u32, vy: u32, ax: u32, ay: u32) -> Span<felt252> {
    //     let mut arr = ArrayTrait::<felt252>::new();
    //     arr.append(px.into());
    //     arr.append(py.into());
    //     arr.append(vx.into());
    //     arr.append(vy.into());
    //     arr.append(ax.into());
    //     arr.append(ay.into());
    //     arr.span()
    // }

    // fn set_physics_entity(
    //     ctx: Context, entity_id: felt252, px: u32, py: u32, vx: u32, vy: u32, ax: u32, ay: u32
    // ) {
    //     ctx
    //         .world
    //         .set_entity(
    //             ctx,
    //             entity_id,
    //             QueryTrait::new(0, 0, phy_component_span(px, py, vx, vy, ax, ay)),
    //             0_u8,
    //             phy_component_span(px, py, vx, vy, ax, ay)
    //         );
    // }

    // fn vec_set_entity(ctx: Context, component: felt252, entity_id: felt252) -> Vec2 {
    //     let mut p = ctx.world.entity(component, entity_id.into(), 0_u8, 0_usize);
    //     serde::Serde::<Vec2>::deserialize(ref p).expect('missing data')
    // }

    fn update_physics(ctx: Context, entity_id: felt252) -> (u32, u32, u32, u32, ) {
        let mut p = vec_entity(ctx, 'Pos', entity_id);
        let mut v = vec_entity(ctx, 'Vel', entity_id);
        let mut a = vec_entity(ctx, 'Acc', entity_id);

        // Add acceleration to velocity
        v.x += a.x - ZERO;
        v.y += a.y - ZERO;
        // Add velocity to position
        p.x += v.x - ZERO;
        p.y += v.y - ZERO;
        (p.x, p.y, v.x, v.y)
    }

    fn execute(ctx: Context) {
        let (mpx, mpy, mvx, mvy, ) = update_physics(ctx, 'mover');
        let (spx, spy, svx, svy, ) = update_physics(ctx, 'seeker');
        commands::set_entity(
            'mover'.into(),
            (Acc { x: ZERO, y: ZERO }, Pos { x: mpx, y: mpy }, Vel { x: mvx, y: mvy }, )
        );
        commands::set_entity(
            'seeker'.into(),
            (Acc { x: ZERO, y: ZERO }, Pos { x: spx, y: spy }, Vel { x: svx, y: svy }, )
        );
        return ();
    }
}
