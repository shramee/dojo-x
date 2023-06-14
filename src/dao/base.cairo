use core::box::BoxTrait;
use core::option::{OptionTrait, Option};
use core::array::ArrayTrait;
use traits::{Into, TryInto, };
use starknet::{
    ContractAddressIntoFelt252, Felt252TryIntoContractAddress, ContractAddress, StorageAccess,
    StorageBaseAddress, SyscallResult, storage_read_syscall, storage_write_syscall,
    storage_address_from_base, storage_address_from_base_and_offset, contract_address_const
};

#[derive(Copy, Drop, Serde)]
enum Actions {
    DistributeFunds: (),
    OpenAdCampaign: (),

}

#[derive(Copy,Drop,Serde)]
struct Proposal {
    id: usize,
    yes_votes: usize,
    no_votes: usize,
    action: Actions
}

impl StorageAccessProposal of StorageAccess<Proposal> {
    fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult<Proposal> {
        let u8_felt_yes = storage_read_syscall(
            address_domain, storage_address_from_base_and_offset(base, 1_u8)
        )?;
        let u8_felt_no = storage_read_syscall(
            address_domain, storage_address_from_base_and_offset(base, 2_u8)
        )?;
            let u8_felt_action = storage_read_syscall(
            address_domain, storage_address_from_base_and_offset(base, 3_u8)
        )?;
        Result::Ok(
            Proposal {
                id: StorageAccess::<usize>::read(address_domain, base)?,
                yes_votes: u8_felt_yes.try_into().expect('Wrong data'),
                no_votes: u8_felt_no.try_into().expect('Wrong data'),
                action: match u8_felt_action {
                    0 => Actions::DistributeFunds(()),
                    _ => Actions::OpenAdCampaign(())
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
    use core::option::OptionTrait;
    use core::array::ArrayTrait;
    use core::box::BoxTrait;

    use starknet::{
    ContractAddressIntoFelt252, Felt252TryIntoContractAddress, ContractAddress, StorageAccess,
    StorageBaseAddress, SyscallResult, storage_read_syscall, storage_write_syscall,
    storage_address_from_base, storage_address_from_base_and_offset, contract_address_const, get_caller_address
};

use debug::PrintTrait;

use super::{Actions, Proposal};
    

    struct Storage {
        members: LegacyMap<ContractAddress, bool>,
        num_members: u32,
        voted: LegacyMap<(u32, ContractAddress), bool>,
        proposals: LegacyMap<u32, Proposal>,
        num_proposals: usize
    }
    
    #[constructor]
    fn constructor(mut initial_members: Array<ContractAddress>) {
        num_members::write(initial_members.len());
        loop {
            if initial_members.is_empty() {
                break ();
            }
            members::write(initial_members.pop_front().unwrap(), true);

        };
        
    }

    #[external]
    fn addProposal(action: Actions) -> u32 {
        num_proposals::write(num_proposals::read() + 1);
        proposals::write(num_proposals::read(), Proposal {
            id: num_proposals::read(),
            yes_votes: 0,
            no_votes: 0,
            action: action
        });
        // return id of added proposal
        num_proposals::read()
    }
    
    #[external]
    fn vote(proposalId: u32, vote: bool) {
        
        assert(members::read(get_caller_address()) == true, 'Caller not in DAO');
        assert(voted::read((proposalId, get_caller_address())) == false, 'Caller has voted');

        voted::write((proposalId, get_caller_address()), true);

        let mut proposal = proposals::read(proposalId);
        
        if vote {
            proposal.yes_votes = proposal.yes_votes + 1;
        }
        else {
            proposal.no_votes = proposal.no_votes + 1;
        }
        proposals::write(proposalId, proposal);
    }

    #[external]
    fn executeProposal(proposalId: u32) {
        let mut proposal_to_execute = proposals::read(proposalId);
        assert(verify_proposal_approved(proposal_to_execute) == true, 'Proposal has not been accepted');
        
        match proposal_to_execute.action {
            Actions::DistributeFunds(_) => execute_fund_distribution(),
            Actions::OpenAdCampaign(_) => execute_open_ad_campaign()
            }
    }

     #[view]
    fn is_member(address_to_check: ContractAddress) -> bool {
        members::read(address_to_check)
    }
    
    #[view]
    fn proposal_accepted(proposal_id: u32) -> bool {
        verify_proposal_approved(proposals::read(proposal_id))
    }

    fn verify_proposal_approved(proposal: Proposal) -> bool {
        let isEven = if num_members::read() % 2 == 0 {
            true
        } else {
            false
        };
        
        if isEven {
            proposal.yes_votes > (num_members::read() / 2)
        } else {
            proposal.yes_votes >= ((num_members::read() + 1) / 2)
        }
    }

    fn execute_fund_distribution() {

    }

    fn execute_open_ad_campaign() {

    }



}

