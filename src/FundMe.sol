// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    // minimum USD people can send
    uint256 public constant MINUSD = 5e18;

    // address of people sending funds and how much they sent
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;

    // define the owner
    address private immutable owner;

    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // allow users to send money
    function fund() public payable {
        // PriceConverter.getConversionRate(msg.value) = msg.value.getConversionRate()
        require(msg.value.getConversionRate(s_priceFeed) >= (MINUSD), "You need to spend more ETH!"); // msg.value : number of wei sent with message
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    // modifier to allow only owner to withdraw
    modifier onlyOwner() {
        // require(msg.sender == owner,"NOT OWNER!");
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    // allow owner to withdraw the money
    function withdraw() public onlyOwner {
        uint256 funderLength = s_funders.length;
        for (uint256 funderIndex = 0; funderIndex < funderLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    // check version of priceFeed
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    // if someone send eth without the fund function
    // call the fund function anyway to run the contract as it is supposed to be
    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    // Getter function
    function getaddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}
