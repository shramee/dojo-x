use traits::Add;
use traits::{Into, TryInto, };
use starknet::{
    ContractAddressIntoFelt252, Felt252TryIntoContractAddress, ContractAddress, StorageAccess,
    StorageBaseAddress, SyscallResult, storage_read_syscall, storage_write_syscall,
    storage_address_from_base, storage_address_from_base_and_offset, contract_address_const
};
use option::OptionTrait;
use result::{Result, ResultTrait};

#[derive(Copy, Drop, Serde)]
struct Vec2 {
    x: u128,
    y: u128
}

impl StorageAccessVec2 of StorageAccess<Vec2> {
    fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult<Vec2> {
        Result::Ok(
            Vec2 {
                x: StorageAccess::<u128>::read(address_domain, base)?,
                y: storage_read_syscall(
                    address_domain, storage_address_from_base_and_offset(base, 1_u8)
                )?
                    .try_into()
                    .expect('StorageAccessVec2 - non Vec2')
            }
        )
    }
    fn write(address_domain: u32, base: StorageBaseAddress, value: Vec2) -> SyscallResult<()> {
        StorageAccess::<u128>::write(address_domain, base, value.x)?;
        storage_write_syscall(
            address_domain, storage_address_from_base_and_offset(base, 1_u8), value.y.into()
        )
    }
}

trait Vec2Trait {
    fn new(x: u128, y: u128) -> Vec2;
    fn zero() -> Vec2;
}

impl Vec2Impl of Vec2Trait {
    fn new(x: u128, y: u128) -> Vec2 {
        Vec2 { x, y }
    }

    fn zero() -> Vec2 {
        Vec2Impl::new(0, 0, )
    }
}

impl Vec2Add of Add<Vec2> {
    fn add(lhs: Vec2, rhs: Vec2) -> Vec2 {
        Vec2 { x: lhs.x + rhs.x, y: lhs.y + rhs.y }
    }
}


#[test]
#[available_gas(2000000)]
fn test_vec_addition() {
    let v1 = Vec2Impl::new(2, 5);
    let v2 = Vec2Impl::new(3, 4);
    let sum = v1 + v2;
    assert(sum.x == v1.x + v2.x, 'Sum is wrong');
    assert(sum.y == v1.y + v2.y, 'Sum is wrong');
}
