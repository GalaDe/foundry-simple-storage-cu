// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26; //stating the version

import "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        vm.startBroadcast(); //vm - special keyword (check foundary cheetcode, only work in foundary)
        SimpleStorage simpleStorage = new SimpleStorage();
        vm.stopBroadcast();
        return simpleStorage;
    }
}
