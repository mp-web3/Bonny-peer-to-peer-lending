// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library LoanMath {
    // Function to calculate interest
    function calculateInterest(uint _principal, uint _scaledInterestRate) public pure returns (uint) {
        return (_principal * _scaledInterestRate) / 10000;
    }

    // Function to convert seconds to days
    function convertSecondsToDays(uint _timeInSeconds) public pure returns (uint) {
        return _timeInSeconds / 60 / 60 / 24;
    }

    // Function to calculate the total due: _principal + interest
    function calculatePrincipalPlusInterest(uint _principal, uint _scaledInterestRate) public pure returns (uint) {
        return _principal + calculateInterest(_principal, _scaledInterestRate);
    }

    // Function to calculate penalty for late repayment
    function calculatePenalty(uint _principal, uint _dueDate, uint _paymentDate) public pure returns (uint) {
        if (_paymentDate <= _dueDate) {
            return 0;
        }
        uint daysLate = convertSecondsToDays(_paymentDate - _dueDate);
        uint scaledPenaltyRate = 10; // represents 0.1%
        // penalty rate is scaled by 10,000
        return (_principal * scaledPenaltyRate * daysLate) / 10000;
    }
}
