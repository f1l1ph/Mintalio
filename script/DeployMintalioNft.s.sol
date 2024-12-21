// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MintalioNFT} from "./../src/MintalioNFT.sol";

contract DeployMintalioNft is Script {
    function run() external returns (MintalioNFT) {
        vm.startBroadcast();
        MintalioNFT mintalioNftContract = new MintalioNFT("some-uri.com");
        vm.stopBroadcast();
        return mintalioNftContract;
    }
}
