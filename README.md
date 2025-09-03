# 💰 Foundry-Cyfrin-FundMe - Decentralized Crowdfunding Contract

![Solidity](https://img.shields.io/badge/Solidity-^0.8.18-363636?style=for-the-badge&logo=solidity)
![Foundry](https://img.shields.io/badge/Foundry-Testing-red?style=for-the-badge&logo=ethereum)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

## 📖 Overview

The Foundry-Cyfrin-FundMe is a decentralized crowdfunding smart contract built on Ethereum that allows users to send ETH donations to a funding campaign. The contract integrates with Chainlink Price Feeds to ensure minimum USD value requirements and includes secure withdrawal mechanisms for the contract owner.

### 🎯 Key Features

• **USD-Based Minimum**: Uses Chainlink Price Feeds to enforce minimum $5 USD equivalent in ETH
• **Multi-Network Support**: Deployable on Mainnet, Sepolia testnet, and local Anvil chain
• **Gas Optimized**: Efficient storage patterns with immutable and constant variables
• **Comprehensive Testing**: Unit, integration, and forked network tests included
• **Secure Withdrawals**: Owner-only withdrawal with proper access control
• **Professional Tooling**: Complete Foundry setup with Makefiles and CI/CD ready

## 🏗️ Architecture & Mechanisms

### Core Components

#### 1. Funding System
• Users can send ETH to fund the contract
• Minimum funding requirement of $5 USD (converted to ETH using Chainlink)
• All funders and their contributions are tracked on-chain
• Automatic fallback and receive functions for direct ETH transfers

#### 2. Price Feed Integration
• Integrates with Chainlink Price Feeds for real-time ETH/USD conversion
• Uses `PriceConverter` library for clean price calculations
• Supports different price feed addresses per network (Mainnet, Sepolia, Local)
• Handles price feed decimals and scaling automatically

#### 3. Access Control & Withdrawals
• Only contract owner can withdraw funds
• Clears all funder records upon withdrawal
• Uses secure low-level call for ETH transfers
• Implements checks-effects-interactions pattern

### 🔧 Technical Mechanisms

#### Chainlink Price Feed Integration
```solidity
// Get latest ETH/USD price from Chainlink
function getPrice() internal view returns (uint256) {
    AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215De4fAc081C51b11De6d8D8a37);
    (, int256 answer,,,) = priceFeed.latestRoundData();
    return uint256(answer * 10000000000); // Convert to 18 decimals
}
```

#### Multi-Network Configuration
```solidity
// Network-specific configurations
if (block.chainid == 1) {
    networkConfig = getMainnetEthConfig(); // Mainnet price feed
} else if (block.chainid == 11155111) {
    networkConfig = getSepoliaEthConfig(); // Sepolia price feed
} else {
    networkConfig = getAnvilEthConfig(); // Local mock
}
```

## 🚀 Getting Started

### Prerequisites

• [Foundry](https://getfoundry.sh/) installed
• [Node.js](https://nodejs.org/) (v16+)
• [Git](https://git-scm.com/)

### Installation

```bash
git clone https://github.com/0xStn/foundry-cyfrin-fundme
cd foundry-cyfrin-fundme
forge install
```

### Environment Setup

Create a `.env` file:
```bash
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
MAIN_ALCHEMY=https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY
PRIVATE_KEY=0x_your_private_key_here
ETHERSCAN_API_KEY=your_etherscan_api_key
```

### Quick Start Commands

```bash
# Build the project
make build

# Run all tests
make test

# Run tests with verbose output
make testv

# Deploy to Sepolia testnet
forge script script/DeployFundme.s.sol:DeployFundme --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## 🧪 Testing

### Test Coverage

The project includes comprehensive test suites:

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test file
forge test --match-path test/FundmeTest.t.sol

# Run on forked networks
forge test --fork-url $SEPOLIA_RPC_URL

# Check test coverage
forge coverage
```

### Test Categories

• **Unit Tests**: Individual function and component testing
• **Integration Tests**: Full workflow testing with mocks
• **Forked Tests**: Testing against real network state
• **Fuzzing Tests**: Random input testing for edge cases

### Network Testing

```bash
# Test on Anvil (local)
forge test

# Test on Sepolia fork
forge test --fork-url $SEPOLIA_RPC_URL

# Test on Mainnet fork
forge test --fork-url $MAIN_ALCHEMY
```

## 💻 Usage Examples

### For Users

1. **Fund the Contract**
```solidity
// Send minimum $5 USD worth of ETH
fundMe.fund{value: 0.003 ether}(); // Adjust based on current ETH price
```

2. **Check Funding Status**
```solidity
uint256 amountFunded = fundMe.getAddressToAmountFunded(userAddress);
address[] memory funders = fundMe.getFunders();
```

### For Contract Owner

1. **Deploy Contract**
```bash
forge script script/DeployFundme.s.sol:DeployFundme --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

2. **Withdraw Funds**
```solidity
// Only owner can call this
fundMe.withdraw();
```

## 📋 Contract Functions

### Public Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `fund()` | Fund the contract with ETH | None (payable) | None |
| `withdraw()` | Withdraw all funds (owner only) | None | None |
| `getVersion()` | Get price feed version | None | uint256 |

### View Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `getAddressToAmountFunded(address)` | Get amount funded by address | uint256 |
| `getFunder(uint256)` | Get funder address by index | address |
| `getOwner()` | Get contract owner | address |
| `getPriceFeed()` | Get price feed contract | AggregatorV3Interface |

## 🌐 Supported Networks

### Mainnet
- **Chain ID**: 1
- **Price Feed**: `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419`
- **Currency Pair**: ETH/USD

### Sepolia Testnet
- **Chain ID**: 11155111
- **Price Feed**: `0x694AA1769357215De4fAc081C51b11De6d8D8a37`
- **Currency Pair**: ETH/USD
- **Faucet**: [Sepolia Faucet](https://sepoliafaucet.com/)

### Local Development (Anvil)
- **Chain ID**: 31337
- **Price Feed**: MockV3Aggregator (deployed automatically)
- **Simulated Price**: $2000 ETH/USD

## ⚡ Pro Tips

### For Users
• **Gas Optimization**: Fund during low network congestion periods
• **Minimum Amount**: Always check current ETH price to meet $5 minimum
• **Transaction Monitoring**: Use Etherscan to track your funding transactions

### For Developers
• **Testing Strategy**: Always test on testnets before mainnet deployment
• **Price Feed Updates**: Monitor Chainlink price feed deprecation notices
• **Security**: Use hardware wallets for mainnet deployments
• **Gas Estimation**: Use `forge snapshot` to track gas usage changes

### Security Considerations
• **Access Control**: Only owner can withdraw funds
• **Price Feed Reliability**: Chainlink provides decentralized price data
• **Reentrancy Protection**: Uses checks-effects-interactions pattern
• **Integer Overflow**: Solidity 0.8+ has built-in overflow protection

## 🔍 Contract Verification

After deployment, verify your contract on Etherscan:

```bash
forge verify-contract \
  --chain-id 11155111 \
  --num-of-optimizations 200 \
  --watch \
  --constructor-args $(cast abi-encode "constructor(address)" 0x694AA1769357215De4fAc081C51b11De6d8D8a37) \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  0xYourContractAddress \
  src/Fundme.sol:FundMe
```

## 📊 Gas Estimates

| Function | Gas Usage | Description |
|----------|-----------|-------------|
| `fund()` | ~50,000 | First-time funding |
| `fund()` | ~35,000 | Subsequent funding |
| `withdraw()` | ~15,000 + (2,300 * funders) | Gas varies with funder count |

## 🛠️ Development Tools

### Makefile Commands
```bash
make build       # Compile contracts
make test        # Run test suite
make testv       # Run tests with verbose output
make clean       # Clean build artifacts
make help        # Show available commands
```

### Foundry Scripts
- `DeployFundme.s.sol`: Main deployment script
- `HelpingConfig.s.sol`: Network-specific configurations
- `MockV3Aggregator.sol`: Local testing price feed mock

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

• [Chainlink Price Feeds Documentation](https://docs.chain.link/data-feeds/price-feeds)
• [Foundry Documentation](https://book.getfoundry.sh/)
• [Solidity Documentation](https://docs.soliditylang.org/)
• [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)

## ⚠️ Disclaimer

This smart contract is provided as-is for educational and development purposes. Users should conduct their own security audits before deploying to mainnet or handling significant value. The developers are not responsible for any financial losses incurred through the use of this contract.

---

Built with ❤️ by [0xSTN](https://github.com/0xStn) | Powered by Chainlink & Foundry
