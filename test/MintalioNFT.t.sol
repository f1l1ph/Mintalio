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

    string public constant PUG_URI = //random URI for penguins NFT
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

    function testCanMintAndHaveABalance() public {
        address user2 = makeAddr("USER-2");

        vm.prank(user2);
        mintalioNft.mint(user2);

        assert(mintalioNft.balanceOf(user2, 0) > 0);
    }

    function testCanMintAndBeNFTOwner() public {
        //testing multiple mints
        vm.prank(USER);
        mintalioNft.mint(USER);
        mintalioNft.mint(USER);
        mintalioNft.mint(USER);

        vm.prank(deployerAddr);
        mintalioNft.addPoints(1, 100);

        assert(mintalioNft.nftOwner(0) == USER);
        assert(mintalioNft.nftOwner(1) == USER);
        assert(mintalioNft.nftOwner(2) == USER);
    }

    function testCanAddPoints() public {
        vm.prank(USER); // invoking user because users can mint
        mintalioNft.mint(USER);

        (uint256 id, uint256 points, uint256 totalPoints, NFTLevel nftLevel) = mintalioNft.nfts(0);
        assert(points == 0 && id == 0 && totalPoints == 0);

        vm.prank(deployerAddr); // invoking the owner because addPoints is onlyAdmin

        mintalioNft.addPoints(0, 1);
        (id, points, totalPoints, nftLevel) = mintalioNft.nfts(0);

        assert(points == 1 && id == 0 && totalPoints == 1);
    }

    function testCanTakePoints() public {
        vm.prank(USER);
        mintalioNft.mint(USER);

        (uint256 id, uint256 points, uint256 totalPoints, NFTLevel nftLevel) = mintalioNft.nfts(0);
        assert(points == 0 && id == 0 && totalPoints == 0);

        vm.prank(deployerAddr);

        mintalioNft.addPoints(0, 1);
        (id, points, totalPoints, nftLevel) = mintalioNft.nfts(0);

        assert(points == 1 && id == 0 && totalPoints == 1);

        console.log("Points before withdrawal: ", points);

        vm.prank(deployerAddr);

        mintalioNft.withdrawPoints(0, 1);
        (id, points, totalPoints, nftLevel) = mintalioNft.nfts(0);

        assert(points == 0 && id == 0 && totalPoints == 1);
    }

    function testHaveLevel() public{
        vm.prank(USER);
        mintalioNft.mint(USER);

        (uint256 id, uint256 points, uint256 totalPoints, NFTLevel nftLevel) = mintalioNft.nfts(0);

        assert(nftLevel == NFTLevel.BRONZE);
        assert(points == 0 && id == 0 && totalPoints == 0);
    }

    function testHaveHigherLevel() public{
        vm.prank(USER);
        mintalioNft.mint(USER);
        mintalioNft.mint(USER);

        (uint256 id, uint256 points, uint256 totalPoints, NFTLevel nftLevel) = mintalioNft.nfts(1);
        assert(nftLevel == NFTLevel.BRONZE);
        assert(points == 0 && id == 1 && totalPoints == 0);

        vm.prank(deployerAddr);
        mintalioNft.addPoints(1, 100);

        (id, points, totalPoints, nftLevel) = mintalioNft.nfts(1);
        assert(nftLevel == NFTLevel.SILVER);
        assert(points == 100 && id == 1 && totalPoints == 100);
    }

    function testCanAddAdmin() public {
        vm.prank(deployerAddr);
        mintalioNft.setAdmin(USER);

        address[] memory admins = mintalioNft.admin();

        assert(admins[1] == USER);
    }

    function testCanRemoveAdmin() public{
        vm.prank(deployerAddr);
        mintalioNft.setAdmin(USER);

        mintalioNft.mint(USER);

        address[] memory admins = mintalioNft.admin();

        assert(admins[1] == USER);

        vm.prank(deployerAddr);
        mintalioNft.removeAdmin(USER);

        admins = mintalioNft.admin();

        assert(admins.length == 1);

        vm.prank(USER);

        //expect revert from addPoints cuz it's onlyAdmin
        vm.expectRevert(MintalioNFT.Not_Contract_Admin.selector);
        mintalioNft.addPoints(1, 100);
    }

    function testCanSendPoints() public{
        vm.prank(USER);
        mintalioNft.mint(USER);
        mintalioNft.mint(USER);
        mintalioNft.mint(USER);

        vm.prank(deployerAddr);
        mintalioNft.addPoints(1, 100);

        (uint256 id, uint256 points, uint256 totalPoints, NFTLevel nftLevel) = mintalioNft.nfts(1);
        assert(points == 100 && id == 1 && totalPoints == 100);

        vm.prank(USER);
        mintalioNft.movePoints(1, 2, 50);

        (id, points, totalPoints, nftLevel) = mintalioNft.nfts(1);
        assert(points == 50 && id == 1 && totalPoints == 100);

        (id, points, totalPoints, nftLevel) = mintalioNft.nfts(2);
        assert(points == 50 && id == 2 && totalPoints == 0);
    }

    function testCannotSendPoints() public{
        vm.prank(USER);
        mintalioNft.mint(USER);
        mintalioNft.mint(USER);

        vm.prank(deployerAddr);
        mintalioNft.addPoints(1, 49);

        vm.prank(USER);
        vm.expectRevert(MintalioNFT.Not_Enough_Points.selector);
        mintalioNft.movePoints(1, 2, 50);
    }

    //write test for setMetadata()
}
