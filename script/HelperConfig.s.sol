// deploy mocks when we are in local chain
// keep track of contract address across different chains

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    // if on local anvil we deploy mock - else we deploy existing address from live network

    // create a data structure to store this address efficiently
    struct NetworkConfig{
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor(){
        if(block.chainid == 11155111) activeNetworkConfig = getSepoliaEthConfig();
        else activeNetworkConfig = getAnvilEthConfig();
    }


    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory){
        // if already deployed mock
        if(activeNetworkConfig.priceFeed != address(0)) return activeNetworkConfig;

        // deploy the mock
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
        vm.stopBroadcast();

        // return the mock address
        NetworkConfig memory anvilConfig = NetworkConfig(
            {priceFeed: address(mockPriceFeed)}
        );
        return anvilConfig;
    }
}