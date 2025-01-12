// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MintalioNFT} from "./../src/MintalioNFT.sol";

contract MintNft is Script {
    address public USER = makeAddr("user");
    string public constant PUG_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "MintalioNFT",
            block.chainid
        );

        // mintNft(mostRecentlyDeployed);
    }

    function mintNft(address contractAddress) public {
        vm.startBroadcast();
        MintalioNFT(contractAddress).mint(USER);
        vm.stopBroadcast();
    }
}
