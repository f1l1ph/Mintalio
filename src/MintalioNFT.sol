// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

struct NFT {
    uint256 id;
    uint256 points;
}

contract MintalioNFT is ERC1155 {
    //TODO: consider: points can be the nfts, if someone owns 1 NFT with id 1 they have 1 point and \
    //if someone owns 2 NFTs with id 1 they have 2 points
    address public owner;
    NFT[] public nfts;

    mapping(uint256 => address) public nftOwners;
    mapping(uint256 => string) private _customUris;

    constructor(string memory _uri) ERC1155(_uri) {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        if (bytes(_customUris[tokenId]).length > 0) {
            return _customUris[tokenId];
        }
        return super.uri(tokenId);
    }

    function mint(address to, bytes memory data) public {
        uint256 id = nfts.length;

        nfts.push(NFT(id, 0));
        nftOwners[id] = to;

        _mint(to, id, 1, data);
        _customUris[id] = string(data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        amount = 1;
        require(
            from == nftOwners[id],
            "ERC1155: caller is not owner nor approved"
        );
        super.safeTransferFrom(from, to, id, amount, data);
        if (amount > 0) {
            nftOwners[id] = to;
        }
    }

    function addPoints(uint256 id, uint256 points) public onlyOwner {
        nfts[id].points += points;
    }

    function withdrawPoints(uint256 id, uint256 points) public onlyOwner {
        require(nfts[id].points >= points, "Not enough points");
        nfts[id].points -= points;
    }
}
