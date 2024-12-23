// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./../script/DeployMintalioNft.s.sol";
import "./../src/MintalioNFT.sol";

contract MintalioNft is Test {
    DeployMintalioNft public deployer;
    MintalioNFT public mintalioNft;

    address public USER = makeAddr("user");

    string public constant PUG_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function setUp() public {
        deployer = new DeployMintalioNft();
        mintalioNft = deployer.run();
    }

    function testUriIsCorrect() public view {
        string memory expectedUri = "some-uri.com";
        string memory actualUri = mintalioNft.uri(0);

        assert(
            keccak256(abi.encodePacked(expectedUri)) ==
                keccak256(abi.encodePacked(actualUri))
        );
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        mintalioNft.mint(USER, bytes(PUG_URI));

        assert(mintalioNft.balanceOf(USER, 0) == 1);

        assert(
            keccak256(abi.encodePacked(mintalioNft.uri(0))) ==
                keccak256(abi.encodePacked(PUG_URI))
        );
    }
}
