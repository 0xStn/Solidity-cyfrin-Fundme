// SPDX-License-Identifier: MIT

// we here making CConfigurations "Mocking" is like a switch channel to run scripts in local chain without relay on other contractschains or oracles
// we can make it to be a substitute for the real feeds of chain link like chain link contracts

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelpingConfig is Script {
    NetworkConfig public networkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            // Sepolia
            networkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            // Mainnet
            networkConfig = getMainnetEthConfig();
        } else {
            // Anvil
            networkConfig = getOrCreateAnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address PriceFeed;
    }

    // Add your helper functions and variables here

    function getSepoliaEthConfig() internal pure returns (NetworkConfig memory) {
        // can returns price feeds
        // gas fees
        NetworkConfig memory sepoliaEthConfig = NetworkConfig({
            PriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // Sepolia ETH/USD price feed address
        });
        return sepoliaEthConfig;
    }

    function getOrCreateAnvilEthConfig() internal returns (NetworkConfig memory) {
        if (networkConfig.PriceFeed != address(0)) {
            return networkConfig; // Return existing config if already set
        }
        // For local tests, deploy a mock and return its address instead.
        vm.startBroadcast();
        MockV3Aggregator mockAggregator = new MockV3Aggregator(18, 2000e8);
        vm.stopBroadcast();
        return NetworkConfig({PriceFeed: address(mockAggregator)});
    }

    function getMainnetEthConfig() internal pure returns (NetworkConfig memory) {
        // can returns price feeds
        // gas fees
        NetworkConfig memory mainnetEthConfig = NetworkConfig({
            PriceFeed: 0x5147eA642CAEF7BD9c1265AadcA78f997AbB9649 // Mainnet ETH/USD price feed address
        });
        return mainnetEthConfig;
    }

    function getPriceFeed() external view returns (address) {
        return networkConfig.PriceFeed;
    }
}
