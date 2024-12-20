// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

struct NFT {
    uint256 id;
    uint256 points;
}

contract MintalioNFT is ERC1155 {
    address public owner;
    NFT[] public nfts;

    mapping(uint256 => address) public nftOwners;

    constructor(string memory uri) ERC1155(uri) {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function mint(address to, bytes memory data) public onlyOwner {
        uint256 id = nfts.length;

        nfts.push(NFT(id, 0));
        nftOwners[id] = to;

        _mint(to, id, 1, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override onlyOwner {
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
}
