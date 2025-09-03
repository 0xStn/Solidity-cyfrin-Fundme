// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../src/Fundme.sol";

import {DeployFundme} from "../script/DeployFundme.s.sol";

contract FundmeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant USER_STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() public {
        DeployFundme deployFundme = new DeployFundme();
        fundMe = deployFundme.run();
        vm.deal(USER, USER_STARTING_BALANCE);
    }

    modifier funder() {
        vm.prank(USER);
        fundMe.fund{value: 1 ether}();
        _;
    }

    function testMinimumUSD() external view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() external view {
        // here is Owner is the address of the contract deployed not me (fundme)
        // msg.sender is the address of the user who called the function
        // console.log("Owner:", fundMe.i_owner());

        console.log("Owner:", fundMe.getOwner());
        console.log("Expected Owner sender :", msg.sender);
        console.log("Deployer:", address(this));

        assertEq(fundMe.getOwner(), msg.sender);
        // assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() external view {
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
            console.log("Sepolia Price Feed Version:", version);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
            console.log("Mainnet Price Feed Version:", version);
        } else {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
            console.log("Anvil Price Feed Version:", version);
        }
    }

    // check the test cheatcodes
    function testExpectrevertETH() external {
        vm.expectRevert(); // that uses for make sure this will fail or revert the transaction
        fundMe.fund{value: 0}();
    }

    ///////////////////////////////////
    function testgetAddressToAmountFunded_msgsender() external {
        vm.prank(msg.sender); // make the user as a msg sender for his transaction
        // as a new user we fund some money to it with deal function ,so we can use it not by msg sender but as message sender
        fundMe.fund{value: 1 ether}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(msg.sender);
        assertEq(amountFunded, 1 ether);
    }

    function testgetAddressToAmountFunded() external {
        vm.prank(USER);
        fundMe.fund{value: 1 ether}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 1 ether);
    }

    ///////////////////////////////////

    function testAddFundersToArrayOfFunders() external {
        vm.prank(USER);
        fundMe.fund{value: 1 ether}();

        vm.prank(msg.sender);
        fundMe.fund{value: 2 ether}();

        address funder1 = fundMe.getFunder(0);
        address funder2 = fundMe.getFunder(1);
        assertEq(funder1, USER);
        assertEq(funder2, msg.sender);

        console.log(
            "Funder 1:",
            funder1,
            "amount funded:",
            fundMe.getAddressToAmountFunded(funder1) / 1e18
        );
        console.log(
            "Funder 2:",
            funder2,
            "amount funded:",
            fundMe.getAddressToAmountFunded(funder2) / 1e18
        );
        console.log(
            "remain funder 1 eths",
            USER_STARTING_BALANCE -
                fundMe.getAddressToAmountFunded(funder1) /
                1e18
        );
    }

    function testsingleOwnerOnlyWithdraw() external {
        // arrange

        uint256 ownerStartingBalance = address(fundMe.getOwner()).balance;
        uint256 fundMeStartingBalance = address(fundMe).balance;

        uint256 gasStart = gasleft(); // there is gas value
        console.log("gas start is ", gasStart);

        //act
        vm.txGasPrice(GAS_PRICE); // calc gas price

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        console.log("gas left is ", gasEnd);

        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // tx.gasprice is now 2
        console.log("gas used is  ", gasUsed);

        //assert
        uint256 ownerEndingBalance = address(fundMe.getOwner()).balance;
        uint256 fundmeEndingBalance = address(fundMe).balance;
        // compare the contract or users balance after withdraw
        assertEq(fundmeEndingBalance, 0);
        // make sure the owner take all contract funds
        assertEq(
            ownerEndingBalance,
            ownerStartingBalance + fundMeStartingBalance
        );
    }

    function testingMultipleFundersWithdraw() external funder {
        // arrange
        uint160 fundersCount = 10;
        uint160 startingFunders = 1;

        for (uint160 i = startingFunders; i < fundersCount; i++) {
            // hoax do (deal and prank)
            // adding different users and funding them
            hoax(address(i), USER_STARTING_BALANCE);
            console.log(
                "Funding user:",
                address(i),
                "with:",
                USER_STARTING_BALANCE / 1e18
            );
            fundMe.fund{value: 1 ether}();
            console.log("User:", address(i), "funded with:", 1 ether / 1e18);
            console.log("contract balance is", address(fundMe).balance);
        }

        console.log("Total contract balance is", address(fundMe).balance);

        uint256 fundmeStartingBalance = address(fundMe).balance;
        uint256 ownerStartingBalance = address(fundMe.getOwner()).balance;

        console.log("Owner balance before withdraw:", ownerStartingBalance);

        // act
        vm.startPrank(fundMe.getOwner());
        console.log("Owner:", fundMe.getOwner(), "is withdrawing funds");
        fundMe.withdraw();
        vm.stopPrank();
        console.log(
            "Owner balance after withdraw:",
            address(fundMe.getOwner()).balance
        );
        // assert

        // check contract is emptied
        uint256 fundMeEndingBalance = address(fundMe).balance;
        uint256 ownerEndingBalance = address(fundMe.getOwner()).balance;
        console.log("Owner ending balance:", ownerEndingBalance);
        console.log(
            ownerStartingBalance,
            fundmeStartingBalance,
            ownerEndingBalance
        );
        assertEq(fundMeEndingBalance, 0);
        assertEq(
            ownerStartingBalance + fundmeStartingBalance,
            ownerEndingBalance
        );

        // // check all funders received their funds
        for (uint160 i = startingFunders; i < fundersCount; i++) {
            // each hoaxed funder started with USER_STARTING_BALANCE and sent 1 ether to the contract,
            // so after funding their balance should be USER_STARTING_BALANCE - 1 ether
            assertEq(address(i).balance, USER_STARTING_BALANCE - 1 ether);
            assertEq(fundMe.getAddressToAmountFunded(address(i)), 0);
        }
    }

    function testingMultipleFundersWithdrawCheaper() external funder {
        // arrange
        uint160 fundersCount = 10;
        uint160 startingFunders = 1;

        for (uint160 i = startingFunders; i < fundersCount; i++) {
            // hoax do (deal and prank)
            // adding different users and funding them
            hoax(address(i), USER_STARTING_BALANCE);
            console.log(
                "Funding user:",
                address(i),
                "with:",
                USER_STARTING_BALANCE / 1e18
            );
            fundMe.fund{value: 1 ether}();
            console.log("User:", address(i), "funded with:", 1 ether / 1e18);
            console.log("contract balance is", address(fundMe).balance);
        }

        console.log("Total contract balance is", address(fundMe).balance);

        uint256 fundmeStartingBalance = address(fundMe).balance;
        uint256 ownerStartingBalance = address(fundMe.getOwner()).balance;

        console.log("Owner balance before withdraw:", ownerStartingBalance);

        // act
        vm.startPrank(fundMe.getOwner());
        console.log("Owner:", fundMe.getOwner(), "is withdrawing funds");
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        console.log(
            "Owner balance after withdraw:",
            address(fundMe.getOwner()).balance
        );
        // assert

        // check contract is emptied
        uint256 fundMeEndingBalance = address(fundMe).balance;
        uint256 ownerEndingBalance = address(fundMe.getOwner()).balance;
        console.log("Owner ending balance:", ownerEndingBalance);
        console.log(
            ownerStartingBalance,
            fundmeStartingBalance,
            ownerEndingBalance
        );
        assertEq(fundMeEndingBalance, 0);
        assertEq(
            ownerStartingBalance + fundmeStartingBalance,
            ownerEndingBalance
        );

        // // check all funders received their funds
        for (uint160 i = startingFunders; i < fundersCount; i++) {
            // each hoaxed funder started with USER_STARTING_BALANCE and sent 1 ether to the contract,
            // so after funding their balance should be USER_STARTING_BALANCE - 1 ether
            assertEq(address(i).balance, USER_STARTING_BALANCE - 1 ether);
            assertEq(fundMe.getAddressToAmountFunded(address(i)), 0);
        }
    }
}
