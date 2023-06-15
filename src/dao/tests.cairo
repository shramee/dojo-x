use core::option::OptionTrait;
use core::array::ArrayTrait;
use core::traits::TryInto;
use super::base::{BaseDAO, Actions};
use starknet::{ContractAddress, contract_address_const};
use starknet::testing::set_caller_address;
use debug::PrintTrait;

#[test]
#[available_gas(1000000000)]
fn test_construct_dao() {
    let mut arr = ArrayTrait::<ContractAddress>::new();
    arr.append(contract_address_const::<0xea8140>());
    arr.append(contract_address_const::<0xea8141>());
    arr.append(contract_address_const::<0xea8142>());

    BaseDAO::constructor(arr);
    let valid_member_1 = BaseDAO::is_member(contract_address_const::<0xea8140>());
    let valid_member_2 = BaseDAO::is_member(contract_address_const::<0xea8141>());
    let valid_member_3 = BaseDAO::is_member(contract_address_const::<0xea8142>());

    let invalid_member_1 = BaseDAO::is_member(contract_address_const::<0xea8145>());

    assert(valid_member_1 == true, 'Valid member');
    assert(valid_member_2 == true, 'Valid member');
    assert(valid_member_3 == true, 'Valid member');

    assert(invalid_member_1 == false, 'Invalid member');
}

#[test]
#[available_gas(1000000000)]
#[should_panic]
fn test_duplicate_vote() {
    let mut arr = ArrayTrait::<ContractAddress>::new();
    arr.append(contract_address_const::<0xea8140>());

    BaseDAO::constructor(arr);

    set_caller_address(contract_address_const::<0xea8140>());

    let proposalId = BaseDAO::addProposal(Actions::DistributeFunds(()));

    // same party will try to vote twice, should revert
    BaseDAO::vote(proposalId, true);
    BaseDAO::vote(proposalId, true);
}

#[test]
#[available_gas(1000000000)]
#[should_panic]
fn test_non_member_vote() {
    let mut arr = ArrayTrait::<ContractAddress>::new();
    arr.append(contract_address_const::<0xea8140>());
    arr.append(contract_address_const::<0xea8141>());
    arr.append(contract_address_const::<0xea8142>());

    BaseDAO::constructor(arr);

    let proposalId = BaseDAO::addProposal(Actions::DistributeFunds(()));

    // caller is not a member, should revert when he tries to vote
    set_caller_address(contract_address_const::<0xea8143>());
    BaseDAO::vote(proposalId, true);
}

#[test]
#[available_gas(1000000000)]
fn test_unpassing_proposal() {
    let mut arr = ArrayTrait::<ContractAddress>::new();
    arr.append(contract_address_const::<0xea8140>());
    arr.append(contract_address_const::<0xea8141>());
    arr.append(contract_address_const::<0xea8142>());

    BaseDAO::constructor(arr);

    let proposalId = BaseDAO::addProposal(Actions::DistributeFunds(()));
    let mut proposalStatus = BaseDAO::proposal_accepted(proposalId);
    assert(proposalStatus == false, 'not passed, no votes');

    set_caller_address(contract_address_const::<0xea8140>());

    // one yes vote, not a majority so shouldn't pass
    BaseDAO::vote(proposalId, true);

    proposalStatus = BaseDAO::proposal_accepted(proposalId);
    assert(proposalStatus == false, 'not passed, no majority');

    // other two parties in DAO will vote no, majority against the proposal
    set_caller_address(contract_address_const::<0xea8141>());
    BaseDAO::vote(proposalId, false);
    
    set_caller_address(contract_address_const::<0xea8142>());
    BaseDAO::vote(proposalId, false);

    proposalStatus = BaseDAO::proposal_accepted(proposalId);
    assert(proposalStatus == false, 'not passed, majority against');
}

#[test]
#[available_gas(1000000000)]
fn test_passing_proposal() {
    let mut arr = ArrayTrait::<ContractAddress>::new();
    arr.append(contract_address_const::<0xea8140>());
    arr.append(contract_address_const::<0xea8141>());
    arr.append(contract_address_const::<0xea8142>());
    arr.append(contract_address_const::<0xea8143>());
    arr.append(contract_address_const::<0xea8144>());
    arr.append(contract_address_const::<0xea8145>());

    BaseDAO::constructor(arr);

    let proposalId = BaseDAO::addProposal(Actions::DistributeFunds(()));

    set_caller_address(contract_address_const::<0xea8140>());
    BaseDAO::vote(proposalId, true);
    set_caller_address(contract_address_const::<0xea8141>());
    BaseDAO::vote(proposalId, true);
    set_caller_address(contract_address_const::<0xea8142>());
    BaseDAO::vote(proposalId, true);
    set_caller_address(contract_address_const::<0xea8143>());
    BaseDAO::vote(proposalId, true);
    set_caller_address(contract_address_const::<0xea8144>());
    BaseDAO::vote(proposalId, false);

    let proposalStatus = BaseDAO::proposal_accepted(proposalId);
    assert(proposalStatus == true, 'passed, 3 of 5');
}

#[test]
#[available_gas(1000000000)]
#[should_panic]
fn test_executing_rejected_proposal() {
    let mut arr = ArrayTrait::<ContractAddress>::new();
    arr.append(contract_address_const::<0xea8140>());
    arr.append(contract_address_const::<0xea8141>());
    arr.append(contract_address_const::<0xea8142>());

    BaseDAO::constructor(arr);

    let proposalId = BaseDAO::addProposal(Actions::DistributeFunds(()));

    set_caller_address(contract_address_const::<0xea8140>());
    BaseDAO::vote(proposalId, true);

    set_caller_address(contract_address_const::<0xea8141>());
    BaseDAO::vote(proposalId, false);
    set_caller_address(contract_address_const::<0xea8142>());
    BaseDAO::vote(proposalId, false);

    let proposalStatus = BaseDAO::proposal_accepted(proposalId);
    assert(proposalStatus == false, 'not passed, majority against');

    BaseDAO::executeProposal(proposalId);
}

#[test]
#[available_gas(1000000000)]
fn test_executing_passed_proposal() {
    let mut arr = ArrayTrait::<ContractAddress>::new();
    arr.append(contract_address_const::<0xea8140>());
    arr.append(contract_address_const::<0xea8141>());
    arr.append(contract_address_const::<0xea8142>());
    arr.append(contract_address_const::<0xea8143>());
    arr.append(contract_address_const::<0xea8144>());

    BaseDAO::constructor(arr);

    let proposalId = BaseDAO::addProposal(Actions::DistributeFunds(()));

    set_caller_address(contract_address_const::<0xea8140>());
    BaseDAO::vote(proposalId, true);
    set_caller_address(contract_address_const::<0xea8143>());
    BaseDAO::vote(proposalId, true);
    set_caller_address(contract_address_const::<0xea8144>());
    BaseDAO::vote(proposalId, true);

    let proposalStatus = BaseDAO::proposal_accepted(proposalId);
    assert(proposalStatus == true, 'passed, 3 of 5 for');

    // execution does nothing atm, but should now be allowed to happen
    BaseDAO::executeProposal(proposalId);
}