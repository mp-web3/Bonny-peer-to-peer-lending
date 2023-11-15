// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract LenderProposal {
    // State variables
    address private loanManager;
    Proposal[] public proposals;

    // Enums
    enum Status { Active, Funded, Canceled, Repaid }

    // Structs
    struct Proposal {
        address payable lender;
        uint principal;
        uint scaledInterestRate;
        uint duration; 
        Status status;
    }

    // Events
    event ProposalActive(uint indexed proposalId, address lender, uint principal, uint scaledInterestRate, uint duration);
    event ProposalFunded(uint indexed proposalId);
    event ProposalCanceled(uint indexed proposalId);
    event ProposalStatusUpdated(uint indexed proposalId, Status newStatus);

    // Modifiers
    modifier onlyLoanManager() {
        require(msg.sender == loanManager, "Caller is not Loan Manager");
        _;
    }

    modifier validProposalId(uint _proposalId) {
        require(_proposalId < proposals.length, "This proposal does not exist");
        _;
    }

    // Constructor
    constructor(address _loanManager) {
        loanManager = _loanManager;
    }

    // External Functions
    function createProposal(uint _scaledInterestRate, uint _duration) external payable {
        require(_scaledInterestRate >= 200 && _scaledInterestRate <= 2000, "Invalid interest rate");
        require(_duration >= 1, "Duration must be at least 1 day");
        require(msg.value > 0, "Principal must be positive");

        Proposal memory newProposal = Proposal(payable(msg.sender), msg.value, _scaledInterestRate, _duration, Status.Active);
        proposals.push(newProposal);
        emit ProposalActive(proposals.length - 1, msg.sender, msg.value, _scaledInterestRate, _duration);
    }

    function cancelProposal(uint _proposalId) external validProposalId(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.lender == msg.sender, "Only lender can cancel");
        require(proposal.status == Status.Active, "Cannot cancel non-active proposal");

        proposal.status = Status.Canceled;
        payable(msg.sender).transfer(proposal.principal);
        emit ProposalCanceled(_proposalId);
    }

    function transferFundsToBorrower(uint _proposalId, address payable borrower) external validProposalId(_proposalId) onlyLoanManager{
        Proposal storage proposal = proposals[_proposalId];

        borrower.transfer(proposal.principal);
    }

    function updateProposalStatus(uint _proposalId, Status _newStatus) external validProposalId(_proposalId) onlyLoanManager {
        Proposal storage proposal = proposals[_proposalId];
        proposal.status = _newStatus;
        emit ProposalStatusUpdated(_proposalId, _newStatus);
    }

    // View Functions
    function getAllProposals() external view returns (address[] memory, uint[] memory, uint[] memory, uint[] memory, Status[] memory) {
        address[] memory lenders = new address[](proposals.length);
        uint[] memory principals = new uint[](proposals.length);
        uint[] memory scaledInterestRates = new uint[](proposals.length);
        uint[] memory durations = new uint[](proposals.length);
        Status[] memory statuses = new Status[](proposals.length);

        for (uint i = 0; i < proposals.length; i++) {
            lenders[i] = proposals[i].lender;
            principals[i] = proposals[i].principal;
            scaledInterestRates[i] = proposals[i].scaledInterestRate;
            durations[i] = proposals[i].duration;
            statuses[i] = proposals[i].status;
        }

        return (lenders, principals, scaledInterestRates, durations, statuses);
    }

    function getProposal(uint _proposalId) public view validProposalId(_proposalId) returns (Proposal memory) {
        return proposals[_proposalId];
    }
}
