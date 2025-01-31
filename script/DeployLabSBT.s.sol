// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {LabSBT} from "../src/LabSBT.sol";
import {console2} from "forge-std/console2.sol";

contract DeployLabSBT is Script {
    function run() external returns (LabSBT) {
        // Configuration parameters
        uint256 mintPrice = 0.1 ether; // Set your desired mint price here

        // Start deployment
        vm.startBroadcast();

        console2.log("Deploying LabSBT contract...");
        console2.log("Mint price:", mintPrice);

        // Deploy LabSBT contract
        LabSBT labSbt = new LabSBT(mintPrice);

        console2.log("LabSBT deployed at:", address(labSbt));

        // Optional: Set initial configuration
        // Example: Enable minting
        // labSbt.setActiveMint(true);

        // Example: Set initial baseURI
        // labSbt.setBaseURI("ipfs://your-base-uri/");

        // Example: Set initial merkle root
        // bytes32 merkleRoot = 0x1234...  // Your merkle root
        // labSbt.updateMerkleRoot(merkleRoot);

        vm.stopBroadcast();

        console2.log("Deployment and setup completed successfully!");
        console2.log("Contract address:", address(labSbt));
        console2.log("Owner address:", msg.sender);

        return labSbt;
    }
}
