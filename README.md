# Technical Documentation - Bonny: Peer-to-Peer Lending Platform

## Document Version
1.0.0

## Document History

| Version | Date       | Description of Change |
|---------|------------|-----------------------|
| 1.0.0   | 2023-11-16 | Initial release       |

## Introduction
This document provides an in-depth technical analysis of the peer-to-peer lending platform developed for Bonny. This blockchain-based solution is designed to democratize access to credit and eliminate the need for traditional financial intermediaries.

## System Overview
The platform is composed of several Smart Contracts deployed on the Ethereum blockchain, providing a secure and transparent environment for peer-to-peer lending activities.

### Components
- **LoanManager.sol**: Central contract managing the lifecycle of loans.
- **LenderProposal.sol**: Contract for managing lenders' proposals.
- **BorrowerRequest.sol**: Contract for handling borrowers' credit requests.
- **LoanMath.sol**: Library for financial calculations.

# Contract Addresses

| Contract Name       | Address                                    |
|---------------------|--------------------------------------------|
| LoanManager.sol     | `0x884c924D52D6c8688E5D4AE0b090A1eda09eEb70` |
| LoanMath.sol        | `0x2d8103552f97C3657e8eC4723fe964BE5e36D461` |
| BorrowerRequest.sol | `0xa190819409F3b4808Fce1A0fDFe00BaaB08b1d48` |
| LenderProposal.sol  | `0x9D498284b718A41a561AE9bE84Cf1Cb9c4b261AB`   |

## Technical Choices

### Solidity
Solidity was chosen for its robustness and wide adoption for writing Ethereum Smart Contracts. It ensures compatibility with the Ethereum Virtual Machine (EVM) and is supported by a rich development ecosystem.

### Smart Contract Architecture
The decision to modularize the platform into multiple contracts was made to ensure separation of concerns, enhance maintainability, and upgradeability.

#### LoanManager.sol
Acts as the orchestrator for the lending process, interfacing with both LenderProposal and BorrowerRequest contracts. It ensures the integrity of transactions and maintains the state of each loan.

#### LenderProposal.sol and BorrowerRequest.sol
These contracts manage proposals and requests respectively. By decoupling them from the LoanManager, we provide flexibility and facilitate the potential for standalone functionalities.

#### LoanMath.sol
A Solidity library used for all mathematical operations to ensure precision and prevent overflows. It handles interest and penalty calculations, crucial for financial integrity.

### Security Considerations
- **Reentrancy Guards**: To prevent reentrancy attacks, we've ensured that all external calls are made after state changes.
- **Access Control**: Modifiers like `onlyOwner` and `validLoan` were used to restrict function execution to authorized users.

## Deployment Strategy
Contracts were deployed on the Goerli Testnet to validate the system's functionality in a live environment akin to the Ethereum mainnet.

### Upgradability
Proxy contracts and the diamond pattern were considered but not implemented in the initial version to keep the system simple and robust.

## Future Enhancements
- Implementation of a governance token for platform decisions.
- Incorporation of a decentralized autonomous organization (DAO) for platform upgrades and decision-making.

## Conclusion
The technical choices made throughout this project were aimed at creating a secure, transparent, and efficient platform for peer-to-peer lending. While the current implementation serves the basic needs, future enhancements are planned to extend the platform's capabilities.
