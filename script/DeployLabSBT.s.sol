// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LabSBT} from "../src/LabSBT.sol";

contract DeployLabSBT is Script {
    function run() external {
        // Get deployer address from keystore
        uint256 mintPrice = 0.1 ether;

        // Start broadcast
        vm.startBroadcast();

        // Deploy using simple new operator
        LabSBT labSbt = new LabSBT{salt: 0}(mintPrice);

        // Optional post-deployment setup
        labSbt.setActiveMint(true);

        vm.stopBroadcast();
    }
}
