// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MintalioNFT
 * @author Filip Masarik
 * @notice This contract implements ERC1155 for a loaylity program using NFTs
 */

struct NFT {
    uint256 id;
    uint256 points;
}

enum NFTLevel {
    BRONZE,
    SILVER,
    GOLD,
    PLATINUM,
    DIAMOND,
    LEGENDARY,
    MYTHIC,
    GODLY,
    IMMORTAL,
    DIVINE,
    CELESTIAL,
    COSMIC,
    ETERNAL,
    INFINITE,
    OMNIPOTENT
}

contract MintalioNFT is ERC1155 {
    error Not_Contract_Owner();
    error Not_NFT_Owner();
    error Not_Enough_Points();

    //TODO: consider: points can be the nfts, if someone owns 1 NFT with id 1 they have 1 point and
    //if someone owns 2 NFTs with id 1 they have 2 points

    address private _owner;
    NFT[] private _nfts;

    mapping(uint256 => address) private _nftOwners;
    mapping(uint256 => string) private _customUris;

    constructor(string memory _uri) ERC1155(_uri) {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert Not_Contract_Owner();
        }
        _;
    }

    function mint(address to, bytes memory data) public {
        uint256 id = _nfts.length + 1;

        _nfts.push(NFT(id, 0));
        _nftOwners[id] = to;

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
        if (from != _nftOwners[id]) {
            revert Not_NFT_Owner();
        }

        amount = 1;
        super.safeTransferFrom(from, to, id, amount, data);
        _nftOwners[id] = to; //consider saving owner metadata, ask about if this is good practice
    }

    function addPoints(uint256 id, uint256 points) public onlyOwner {
        _nfts[id].points += points;
    }

    function withdrawPoints(uint256 id, uint256 points) public onlyOwner {
        if (_nfts[id].points < points) {
            revert Not_Enough_Points();
        }

        _nfts[id].points -= points;
    }

    function nfts(uint256 id) public view returns (uint256, uint256) {
        return (_nfts[id].id, _nfts[id].points);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function balanceOf(
        address account,
        uint256 id
    ) public view override returns (uint256) {
        return super.balanceOf(account, id);
    }

    function nftOwner(uint256 id) public view returns (address) {
        return _nftOwners[id];
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        //TODO: ask about this thang
        if (bytes(_customUris[tokenId]).length > 0) {
            return _customUris[tokenId];
        }

        return super.uri(tokenId);
    }
}
