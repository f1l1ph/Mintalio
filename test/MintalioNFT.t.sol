// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./../script/DeployMintalioNft.s.sol";
import "./../src/MintalioNFT.sol";

// import {Console} from "lib/forge-std/src";

contract MintalioNft is Test {
    DeployMintalioNft public deployer;
    address public deployerAddr;
    MintalioNFT public mintalioNft;

    address public USER = makeAddr("user");

    string public constant PUG_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function setUp() public {
        deployer = new DeployMintalioNft();
        mintalioNft = deployer.run();
        deployerAddr = deployer.getDeployer();
    }

    function testUriIsCorrect() public view {
        string memory expectedUri = "some-uri.com";
        string memory actualUri = mintalioNft.uri(0);

        assert(
            keccak256(abi.encodePacked(expectedUri)) ==
                keccak256(abi.encodePacked(actualUri))
        );
    }

    function testUriIsCorrect2() public {
        string memory expectedUri = "some-uri.com";

        //minting a new NFT
        vm.prank(USER);
        mintalioNft.mint(USER, bytes(PUG_URI));

        string memory actualUri = mintalioNft.uri(1);

        assert(
            keccak256(abi.encodePacked(expectedUri)) !=
                keccak256(abi.encodePacked(actualUri))
        );
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        mintalioNft.mint(USER, bytes(PUG_URI));

        assert(mintalioNft.balanceOf(USER, 1) == 1);

        assert(
            keccak256(abi.encodePacked(mintalioNft.uri(1))) ==
                keccak256(abi.encodePacked(PUG_URI))
        );
    }

    function testCanAddPoints() public {
        vm.prank(USER); // invoking user because users can mint
        mintalioNft.mint(USER, bytes(PUG_URI));

        (uint256 id, uint256 points) = mintalioNft.nfts(0);
        assert(points == 0 && id == 1);

        vm.prank(deployerAddr); // invoking the owner because addPoints is onlyOwner

        mintalioNft.addPoints(0, 1);
        (id, points) = mintalioNft.nfts(0);

        assert(points == 1 && id == 1);
    }

    function testCanTakePoints() public {
        vm.prank(USER);
        mintalioNft.mint(USER, bytes(PUG_URI));

        (uint256 id, uint256 points) = mintalioNft.nfts(0);
        assert(points == 0 && id == 1);

        vm.prank(deployerAddr);

        mintalioNft.addPoints(0, 1);
        (id, points) = mintalioNft.nfts(0);

        assert(points == 1 && id == 1);

        console.log("Points before withdrawal: ", points);

        vm.prank(deployerAddr);

        mintalioNft.withdrawPoints(0, 1);
        (id, points) = mintalioNft.nfts(0);

        assert(points == 0 && id == 1);
    }
}
