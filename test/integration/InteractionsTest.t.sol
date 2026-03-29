// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant TX_SEND_VAL = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe dpm = new DeployFundMe();
        fundMe = dpm.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe ffm = new FundFundMe();
        ffm.fundFundMe(address(fundMe));

        WithdrawFundMe wfm = new WithdrawFundMe();
        wfm.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
