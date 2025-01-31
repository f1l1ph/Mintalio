// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./../../script/DeployMintalioNft.s.sol";
import "./../../src/MintalioNFT.sol";

// import {Console} from "lib/forge-std/src";

contract BasicFlowTest is Test {
    DeployMintalioNft public deployer;
    address public deployerAddr;
    MintalioNFT public mintalioNft;

    address public USER = makeAddr("user");

    function setUp() public {
        deployer = new DeployMintalioNft();
        mintalioNft = deployer.run();
        deployerAddr = deployer.getDeployer();
    }

    //@dev flow of this test:
    // mint nft
    // set uri
    // check if uri is correct
    // add points
    // get level
    // add more points
    // mint bunch of new nfts
    // transfer points to another nft

    function test() public {
        vm.prank(USER);
        mintalioNft.mint(USER);

        mintalioNft.setURI("some-uri.com", 0);

        assert(
            keccak256(abi.encodePacked(mintalioNft.uri(0))) ==
                keccak256(abi.encodePacked("some-uri.com"))
        );

        mintalioNft.addPoints(0, 100);
        (
            uint256 id,
            uint256 points,
            uint256 totalPoints,
            NFTLevel nftLevel
        ) = mintalioNft.nfts(0);

        assert(points == 100);
        assert(totalPoints == 100);
        assert(nftLevel == NFTLevel.BRONZE);
        assert(id == 0);
    }
}
