// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./LoanMath.sol";
import "./LenderProposal.sol";
import "./BorrowerRequest.sol";

contract LoanManager {
    LenderProposal private lenderProposal;
    BorrowerRequest private borrowerRequest;
    address public owner;
    uint public loanCount;
    mapping(uint => Loan) public loans;

    struct Loan {
        address borrower;
        address lender;
        uint proposalId;
        uint requestId;
        uint amount;
        uint interestRate;
        uint startTime;
        uint endTime;
        bool isActive;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier validLoan(uint loanId) {
        require(loanId < loanCount, "Loan does not exist");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setLenderProposal(address _lenderProposal) external onlyOwner {
        require(address(lenderProposal) == address(0), "LenderProposal address has already been set");
        lenderProposal = LenderProposal(_lenderProposal);
    }

    function setBorrowerRequest(address _borrowerRequest) external onlyOwner {
        require(address(borrowerRequest) == address(0), "BorrowerRequest address has already been set");
        borrowerRequest = BorrowerRequest(_borrowerRequest);
    }

    function fundLoanRequest(uint proposalId, uint requestId) external {
        LenderProposal.Proposal memory proposal = lenderProposal.getProposal(proposalId);
        BorrowerRequest.Request memory request = borrowerRequest.getRequest(requestId);

        require(proposal.lender == msg.sender, "Only proposal creator can fund");
        require(proposal.status == LenderProposal.Status.Active, "Proposal already funded or canceled");
        require(request.principal == proposal.principal, "Amount must be equal to proposal principal");
        require(request.scaledInterestRate == proposal.scaledInterestRate, "Interest must be the same");
        require(request.status == BorrowerRequest.Status.Active, "Request already funded or canceled");

        loans[loanCount] = Loan(request.borrower, msg.sender, proposalId, requestId, request.principal, proposal.scaledInterestRate, block.timestamp, block.timestamp + request.duration * 1 days, true);
        loanCount++;

        lenderProposal.updateProposalStatus(proposalId, LenderProposal.Status.Funded);
        borrowerRequest.updateRequestStatus(requestId, BorrowerRequest.Status.Funded);
        lenderProposal.transferFundsToBorrower(proposalId, payable(request.borrower));
    }

    function acceptLoanProposal(uint proposalId, uint requestId) external {
        LenderProposal.Proposal memory proposal = lenderProposal.getProposal(proposalId);
        BorrowerRequest.Request memory request = borrowerRequest.getRequest(requestId);

        require(request.borrower == msg.sender, "Only request creator can be funded");
        require(request.status == BorrowerRequest.Status.Active, "Request is not Active");
        require(request.principal == proposal.principal, "Amount must be equal to proposal principal");
        require(request.scaledInterestRate == proposal.scaledInterestRate, "Interest must be the same");
        require(proposal.status == LenderProposal.Status.Active, "Proposal is not Active");

        loans[loanCount] = Loan(msg.sender, proposal.lender, proposalId, requestId, proposal.principal, proposal.scaledInterestRate, block.timestamp, block.timestamp + proposal.duration * 1 days, true);
        loanCount++;

        lenderProposal.updateProposalStatus(proposalId, LenderProposal.Status.Funded);
        borrowerRequest.updateRequestStatus(requestId, BorrowerRequest.Status.Funded);
        lenderProposal.transferFundsToBorrower(proposalId, payable(msg.sender));
    }

    function repayLoan(uint loanId) external payable validLoan(loanId) {
        Loan storage loan = loans[loanId];
        require(loan.borrower == msg.sender, "Only borrower can repay");
        require(loan.isActive, "Loan is not active");

        uint dueAmount = LoanMath.calculatePrincipalPlusInterest(loan.amount, loan.interestRate);
        if (block.timestamp > loan.endTime) {
            dueAmount += LoanMath.calculatePenalty(loan.amount, loan.endTime, block.timestamp);
        }

        require(msg.value == dueAmount, "Incorrect repayment amount");

        loan.isActive = false;
        lenderProposal.updateProposalStatus(loan.proposalId, LenderProposal.Status.Repaid);
        borrowerRequest.updateRequestStatus(loan.requestId, BorrowerRequest.Status.Repaid);
        payable(loan.lender).transfer(msg.value);
    }

    function checkLoanStatus(uint loanId) public view validLoan(loanId) returns (string memory status, int daysRemaining) {
        Loan memory loan = loans[loanId];

        if (!loan.isActive) {
            return ("Inactive", 0);
        }

        daysRemaining = int(LoanMath.convertSecondsToDays(loan.endTime - block.timestamp));
        if (daysRemaining >= 0) {
            return ("Active, days to expiration", daysRemaining);
        } else {
            return ("Expired, days overdue", daysRemaining);
        }
    }

    function getLoan(uint loanId) public view validLoan(loanId) returns (Loan memory) {
        return loans[loanId];
    }

    function calculateTotalAmountDue(uint loanId) public view validLoan(loanId) returns (string memory status, uint totalDue) {
        Loan memory loan = loans[loanId];

        if (!loan.isActive) {
            return ("Inactive", 0);
        }

        totalDue = LoanMath.calculatePrincipalPlusInterest(loan.amount, loan.interestRate);
        if (block.timestamp > loan.endTime) {
            totalDue += LoanMath.calculatePenalty(loan.amount, loan.endTime, block.timestamp);
        }

        return ("Total due amount is", totalDue);
    }
}
