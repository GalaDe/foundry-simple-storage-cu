// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
    }

    function testInitialNumberIsZero() public view {
        assertEq(counter.number(), 0);
    }

    function testSetNumber() public {
        counter.setNumber(42);
        assertEq(counter.number(), 42);
    }

    function testIncrement() public {
        counter.setNumber(5);
        counter.increment();
        assertEq(counter.number(), 6);
    }

    function testMultipleIncrements() public {
        counter.increment();
        counter.increment();
        assertEq(counter.number(), 2);
    }
}