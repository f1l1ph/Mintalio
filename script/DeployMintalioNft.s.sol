// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MintalioNFT} from "./../src/MintalioNFT.sol";

contract DeployMintalioNft is Script {
    address private deployer;

    function run() external returns (MintalioNFT) {
        vm.startBroadcast();
        MintalioNFT mintalioNftContract = new MintalioNFT("some-uri.com");
        deployer = mintalioNftContract.owner();
        vm.stopBroadcast();
        return mintalioNftContract;
    }

    function getDeployer() external view returns (address) {
        return deployer;
    }
}
