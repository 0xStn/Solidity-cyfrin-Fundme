// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {FundMe} from "../src/Fundme.sol";

import {Script} from "forge-std/Script.sol";

import {HelpingConfig} from "script/HelpingConfig.s.sol";

contract DeployFundme is Script {
    function run() external returns (FundMe) {
        HelpingConfig helperConfig = new HelpingConfig();

        address pricefeed = helperConfig.networkConfig();
        // any thing before broadcast is not TX //////

        vm.startBroadcast();
        // any thing after broadcast is  TX
        FundMe fundMe = new FundMe(pricefeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
