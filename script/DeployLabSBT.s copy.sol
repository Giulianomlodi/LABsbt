// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LabSBT} from "../src/LabSBT.sol";

contract DeployLabSBT is Script {
    function run() external returns (LabSBT) {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_KEY");

        // Configuration
        uint256 mintPrice = 0.1 ether;

        // Start broadcast
        vm.startBroadcast(deployerPrivateKey);

        // Deploy contract
        LabSBT labSbt = new LabSBT(mintPrice);

        vm.stopBroadcast();

        return labSbt;
    }
}
