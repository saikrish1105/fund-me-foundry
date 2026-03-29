# FundMe

A Foundry-based smart contract project for crowdfunding with ETH and USD price feeds.

## Overview

FundMe is a Solidity smart contract that allows users to fund a project with ETH. The contract uses Chainlink's price feed to ensure minimum funding requirements in USD and allows the owner to withdraw funds.

## Features

- **Fund contract**: Users can send ETH (minimum $5 USD equivalent)
- **Price conversion**: Automatically converts ETH amounts to USD using Chainlink oracles
- **Owner withdraw**: Only the contract owner can withdraw all funds
- **Funder tracking**: Keeps track of all funders and their contributions

## Project Structure

```
src/
  ├── FundMe.sol          # Main contract
  └── PriceConverter.sol   # Price conversion utilities

script/
  ├── DeployFundMe.s.sol   # Deployment script
  ├── HelperConfig.s.sol   # Network configuration
  └── Interactions.s.sol   # Funding and withdrawal scripts

test/
  ├── unit/
  │   └── FundMeTest.t.sol           # Unit tests
  └── integration/
      └── InteractionsTest.t.sol     # Integration tests
```

## Getting Started

### Requirements

- Foundry (forge, anvil, cast)
- Solc 0.8.33 or compatible

### Installation

```bash
forge install
```

### Testing

Run all tests:
```bash
forge test
```

Run a specific test:
```bash
forge test --match-test <test_name> -vvv
```

### Deployment

Deploy to a local network:
```bash
forge script script/DeployFundMe.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

## License

MIT
