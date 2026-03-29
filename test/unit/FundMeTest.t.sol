// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // returns an address to use
    address USER = makeAddr("user");
    uint256 constant TX_SEND_VAL = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    // modifiers
    modifier funded() {
        vm.prank(USER); // next tx will be sent by address USER
        fundMe.fund{value: TX_SEND_VAL}();
        _;
    }

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe dpm = new DeployFundMe();
        fundMe = dpm.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINUSD(), 5e18);
    }

    function testOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailNotEnoughEth() public {
        vm.expectRevert(); // the next call should fail
        fundMe.fund(); // sending 0 Eth is an error - so test will fail
    }

    function testFundUpdatesFundDataStructure() public funded {
        uint256 amountFunded = fundMe.getaddressToAmountFunded(USER);
        assertEq(amountFunded, TX_SEND_VAL);
    }

    function testAddsFunderToArray() public funded {
        address senderAddress = fundMe.getFunders(0);
        assertEq(senderAddress, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdraw() public funded {
        // ARRANGE
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // ACT
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // ASSERT
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleUsers() public funded {
        for (uint160 i = 1; i < 10; i++) {
            hoax(address(i), TX_SEND_VAL);
            fundMe.fund{value: TX_SEND_VAL}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assert(endingFundMeBalance == 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }
}
