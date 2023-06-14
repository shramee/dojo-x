use traits::{Into, TryInto, };
use option::{OptionTrait, Option};
use starknet::{
    ContractAddressIntoFelt252, Felt252TryIntoContractAddress, ContractAddress, StorageAccess,
    StorageBaseAddress, SyscallResult, storage_read_syscall, storage_write_syscall,
    storage_address_from_base, storage_address_from_base_and_offset, contract_address_const
};

#[derive(Drop)]
enum Actions {
    DistributeFunds: (),
    OpenAdCampaign: (),

}

#[derive(Drop)]
struct Proposal {
    id: usize,
    yes_votes: u8,
    no_votes: u8,
    action: Actions
}

impl StorageAccessProposal of StorageAccess<Proposal> {
    fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult<Proposal> {
        let addr_felt = storage_read_syscall(
            address_domain, storage_address_from_base_and_offset(base, 1_u8)
        )?;
        let u8_felt_yes = storage_read_syscall(
            address_domain, storage_address_from_base_and_offset(base, 2_u8)
        )?;
        let u8_felt_no = storage_read_syscall(
            address_domain, storage_address_from_base_and_offset(base, 3_u8)
        )?;
            let u8_felt_action = storage_read_syscall(
            address_domain, storage_address_from_base_and_offset(base, 4_u8)
        )?;
        Result::Ok(
            Proposal {
                id: StorageAccess::<usize>::read(address_domain, base)?,
                yes_votes: u8_felt_yes.try_into().expect('StorageAccessProposal - wrong data'),
                no_votes: u8_felt_no.try_into().expect('StorageAccessProposal - wrong data'),
                action: match u8_felt_action {
                    0 => Actions::DistributeFunds(()),
                    1 => Actions::OpenAdCampaign(()),
                    // fix this to throw an error
                    _ => Actions::DistributeFunds(())
                }
            }
        )
    }
    fn write(address_domain: u32, base: StorageBaseAddress, value: Proposal) -> SyscallResult<()> {
        StorageAccess::<felt252>::write(address_domain, base, value.id.into())?;
        storage_write_syscall(
            address_domain, storage_address_from_base_and_offset(base, 1_u8), value.yes_votes.into()
        );
        storage_write_syscall(
            address_domain, storage_address_from_base_and_offset(base, 2_u8), value.no_votes.into()
        );
        storage_write_syscall(
            address_domain, storage_address_from_base_and_offset(base, 3_u8), 
            match value.action {
                Actions::DistributeFunds(_) => 0,
                Actions::OpenAdCampaign(_) => 1
                }
        )
    }
}

#[contract]
mod BaseDAO {
    

    struct Storage {
        members: LegacyMap<ContractAddress, bool>,
        proposals: LegacyMap<u8, Proposal>,
        num_proposals: usize
    }

    fn constructor(members: Array<ContractAddress>) {
        members::write(0_u8);
    }

    fn addProposal(action: Actions) {
        num_proposals::write(num_proposals::read() + 1);
        proposals::write(num_proposals::read(), Proposal {
            id: num_proposals::read(),
            yes_votes: 0,
            no_votes: 0,
            action: action
        });
    }

    fn vote(proposalId: u8, vote: bool) {
        proposals::read(proposalId).yes_votes
    }
}

