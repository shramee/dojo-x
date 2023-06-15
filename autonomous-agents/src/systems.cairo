use dojo_core::storage::query::{Query, QueryTrait};
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
    use dojo_autonomous_agents::components::{Pos, Vel, Acc, ZERO, val_from_2xpc};
    use debug::PrintTrait;

    fn execute(ctx: Context) {
        let (mut p, mut v, a) = commands::<Pos, Vel, Acc>::entity('mover'.into());

        // Add acceleration to velocity
        v.x += a.x - ZERO;
        v.y += a.y - ZERO;
        // Add velocity to position
        p.x += v.x - ZERO;
        p.y += v.y - ZERO;

        let uh = commands::set_entity(
            'mover'.into(),
            (Acc { x: ZERO, y: ZERO }, Pos { x: p.x, y: p.y }, Vel { x: v.x, y: v.y }, )
        );
        return ();
    }
}
