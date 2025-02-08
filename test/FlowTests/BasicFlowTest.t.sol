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

    function testbasicFlow() public {
        setUp();

        vm.prank(USER);
        mintalioNft.mint(USER);

        vm.prank(deployerAddr);
        mintalioNft.setURI("some-uri.com", 0);

        assert(
            keccak256(abi.encodePacked(mintalioNft.uri(0))) ==
                keccak256(abi.encodePacked("some-uri.com"))
        );

        vm.prank(deployerAddr);
        mintalioNft.addPoints(0, 50);
        (
            uint256 id,
            uint256 points,
            uint256 totalPoints,
            NFTLevel nftLevel
        ) = mintalioNft.nfts(0);

        assert(points == 50 && totalPoints == 50 && id == 0);

        // for (uint i = 0; i < 100; i++) {
        //     mintalioNft.mint(USER);
        // }
        vm.prank(deployerAddr);
        mintalioNft.addPoints(0, 50);

        (id, points, totalPoints, nftLevel) = mintalioNft.nfts(0);

        assert(points == 100 && totalPoints == 100 && id == 0);

        vm.prank(USER);
        mintalioNft.movePoints(0, 1, 100);

        (id, points, totalPoints, nftLevel) = mintalioNft.nfts(1);
        assert(points == 100 && totalPoints == 100 && id == 1);

        (id, points, totalPoints, nftLevel) = mintalioNft.nfts(0);
        assert(points == 0 && totalPoints == 100 && id == 0);
    }
}
