// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {MockV3Aggregator} from "../../test/mocks/MockV3Aggregator.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    MockV3Aggregator mockV3;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_ANSWER = 2000e8; // ETH/USD = 2000
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        mockV3 = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        fundMe = new FundMe(address(mockV3));
        vm.deal(USER, STARTING_BALANCE);
    }

    /* ------------ Constructor & basic funding ---------- */

    receive() external payable {}

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // Fund with 0 ETH must revert
        fundMe.fund();
    }

    function testFundUpdatesDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArray() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    /* ------------ Helper modifier: contract is funded --- */
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    /* ------------ Withdraw tests ----------------------- */

    function testOnlyOwnerCanWithdraw() public funded {
        // Call withdraw as a NON-owner (USER) and expect a revert
        vm.startPrank(USER);
        vm.expectRevert();
        fundMe.withdraw();
        vm.stopPrank();
    }

    function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        //sets up the transaction gas price for the next transaction
        vm.txGasPrice(GAS_PRICE);
        //`gasleft()` to find out how much gas we had before and after we called the transaction
        uint256 gasStart = gasleft();

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Withdraw consumed: %d gas", gasUsed);

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawMultipleFunders() public funded {
        uint160 numFunders = 10;
        for (uint160 i = 1; i <= numFunders; i++) {
            hoax(address(i), SEND_VALUE); // deal + prank
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMe = address(fundMe).balance;
        uint256 startingOwner = fundMe.getOwner().balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(startingFundMe + startingOwner, fundMe.getOwner().balance);
        // owner gained (numFunders + USER) * SEND_VALUE
        assertEq(
            (numFunders + 1) * SEND_VALUE,
            fundMe.getOwner().balance - startingOwner
        );
    }
}
