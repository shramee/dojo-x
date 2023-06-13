use traits::{Into, TryInto, };
use starknet::{
    ContractAddressIntoFelt252, Felt252TryIntoContractAddress, ContractAddress, StorageAccess,
    StorageBaseAddress, SyscallResult, storage_read_syscall, storage_write_syscall,
    storage_address_from_base, storage_address_from_base_and_offset, contract_address_const
};
use option::OptionTrait;
use result::{Result, ResultTrait};

#[derive(Drop, Serde)]
struct World {
    name: felt252,
    addr: ContractAddress,
}

impl StorageAccessWorld of StorageAccess<World> {
    fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult<World> {
        let addr_felt = storage_read_syscall(
            address_domain, storage_address_from_base_and_offset(base, 1_u8)
        )?;
        Result::Ok(
            World {
                name: StorageAccess::<felt252>::read(address_domain, base)?,
                addr: addr_felt.try_into().expect('StorageAccessWorld - wrong data')
            }
        )
    }
    fn write(address_domain: u32, base: StorageBaseAddress, value: World) -> SyscallResult<()> {
        StorageAccess::<felt252>::write(address_domain, base, value.name)?;
        storage_write_syscall(
            address_domain, storage_address_from_base_and_offset(base, 1_u8), value.addr.into()
        )
    }
}
#[contract]
mod Universe {
    use starknet::{ContractAddress, contract_address_const};
    use debug::PrintTrait;
    use array::ArrayTrait;
    use super::World;
    struct Storage {
        worlds: LegacyMap<usize, World>,
        world_names: LegacyMap<felt252, World>,
        worlds_count: usize,
    }

    #[event]
    fn WorldRegistered(world: World) {}

    #[external]
    fn register_world(name: felt252, addr: ContractAddress) {
        let world_exists = world_names::read(name).addr;
        assert(contract_address_const::<0>() == world_exists, 'World already exists');

        let wi = worlds_count::read();
        worlds_count::write(wi + 1);
        worlds::write(wi, World { name, addr });
        world_names::write(name, World { name, addr });
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
            arr.append(worlds::read(i));
            i += 1;
        };
        arr
    }
}
