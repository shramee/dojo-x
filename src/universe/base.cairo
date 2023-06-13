use starknet::ContractAddress;

#[derive(Drop, Serde)]
struct World {
    name: felt252,
    addr: ContractAddress,
}

#[contract]
mod Universe {
    use starknet::{ContractAddress, contract_address_const};
    use debug::PrintTrait;
    use array::ArrayTrait;
    use super::World;
    struct Storage {
        worlds: LegacyMap<usize, felt252>,
        world_addr: LegacyMap<felt252, ContractAddress>,
        worlds_count: usize,
    }

    #[event]
    fn WorldRegistered(world: World) {}

    #[external]
    fn register_world(world_name: felt252, world_addr: ContractAddress) -> usize {
        let world_exists = world_addr::read(world_name);
        assert(contract_address_const::<0>() == world_exists, 'World already exists');

        let wi = worlds_count::read();
        worlds_count::write(wi + 1);
        world_addr::write(world_name, world_addr);
        worlds::write(wi, world_name);
        wi
    }

    #[view]
    fn get_worlds() -> Array::<World> {
        let mut arr = ArrayTrait::<World>::new();
        let num_items = worlds_count::read();
        let mut i: usize = 0;
        loop {
            if num_items <= i {
                break ();
            }
            let name = worlds::read(i);
            arr.append(World { name, addr: world_addr::read(name),  });
            i += 1;
        };
        arr
    }
}
