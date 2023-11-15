// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract BorrowerRequest {
    // State variables
    address private loanManager;
    Request[] public requests;

    // Enums
    enum Status { Active, Funded, Canceled, Repaid }

    // Structs
    struct Request {
        address borrower;
        uint principal;
        uint scaledInterestRate;
        uint duration; 
        Status status;
    }

    // Events
    event RequestActive(uint indexed requestId, address borrower, uint principal, uint scaledInterestRate, uint duration);
    event RequestFunded(uint indexed requestId);
    event RequestCanceled(uint indexed requestId);
    event RequestStatusUpdated(uint indexed requestId, Status newStatus);

    // Modifiers
    modifier onlyLoanManager() {
        require(msg.sender == loanManager, "Caller is not Loan Manager");
        _;
    }

    modifier validRequestId(uint _requestId) {
        require(_requestId < requests.length, "This request does not exist");
        _;
    }

    // Constructor
    constructor(address _loanManager) {
        loanManager = _loanManager;
    }

    // External Functions
    function createRequest(uint _principal, uint _scaledInterestRate, uint _duration) external {
        require(_principal > 0, "Principal must be greater than 0");
        require(_scaledInterestRate >= 200 && _scaledInterestRate <= 2000, "Invalid interest rate");
        require(_duration >= 1, "Duration must be at least 1 day");

        Request memory newRequest = Request(msg.sender, _principal, _scaledInterestRate, _duration, Status.Active);
        requests.push(newRequest);
        emit RequestActive(requests.length - 1, msg.sender, _principal, _scaledInterestRate, _duration);
    }

    function cancelRequest(uint _requestId) external validRequestId(_requestId) {
        Request storage request = requests[_requestId];
        require(request.borrower == msg.sender, "Only the borrower can cancel");
        require(request.status == Status.Active, "Cannot cancel non-active request");

        request.status = Status.Canceled;
        emit RequestCanceled(_requestId);
    }

    function updateRequestStatus(uint _requestId, Status _newStatus) external validRequestId(_requestId) onlyLoanManager {
        Request storage request = requests[_requestId];
        request.status = _newStatus;
        emit RequestStatusUpdated(_requestId, _newStatus);
    }

    // View Functions
    function getAllRequests() external view returns (address[] memory, uint[] memory, uint[] memory, uint[] memory, Status[] memory) {
        address[] memory borrowers = new address[](requests.length);
        uint[] memory principals = new uint[](requests.length);
        uint[] memory scaledInterestRates = new uint[](requests.length);
        uint[] memory durations = new uint[](requests.length);
        Status[] memory statuses = new Status[](requests.length);

        for (uint i = 0; i < requests.length; i++) {
            borrowers[i] = requests[i].borrower;
            principals[i] = requests[i].principal;
            scaledInterestRates[i] = requests[i].scaledInterestRate;
            durations[i] = requests[i].duration;
            statuses[i] = requests[i].status;
        }

        return (borrowers, principals, scaledInterestRates, durations, statuses);
    }

    function getRequest(uint _requestId) public view validRequestId(_requestId) returns (Request memory) {
        return requests[_requestId];
    }
}
