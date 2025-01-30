// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "forge-std/console.sol";

/**
 * @title MintalioNFT
 * @author Filip Masarik
 * @notice This contract implements ERC1155 for a loaylity program using NFTs
 */

struct NFT {
    uint256 id;
    uint256 points;
    uint256 totalPoints;
    NFTLevel level;
}
enum NFTLevel {
    BRONZE, //0
    SILVER, //1
    GOLD, //2
    PLATINUM, //3
    DIAMOND, //4
    LEGENDARY, //5
    MYTHIC, //6
    GODLY, //7
    IMMORTAL, //8
    DIVINE, //9
    CELESTIAL, //10
    COSMIC, //11
    ETERNAL, //12
    INFINITE, //13
    OMNIPOTENT //14
}

// Points required for each level
// mapping(NFTLevel => uint256) levelPoints = {
//     NFTLevel.BRONZE: 0,
//     NFTLevel.SILVER: 100,
//     NFTLevel.GOLD: 250,
//     NFTLevel.PLATINUM: 500,
//     NFTLevel.DIAMOND: 1000,
//     NFTLevel.LEGENDARY: 2000,
//     NFTLevel.MYTHIC: 4000,
//     NFTLevel.GODLY: 8000,
//     NFTLevel.IMMORTAL: 16000,
//     NFTLevel.DIVINE: 32000,
//     NFTLevel.CELESTIAL: 64000,
//     NFTLevel.COSMIC: 128000,
//     NFTLevel.ETERNAL: 256000,
//     NFTLevel.INFINITE: 512000,
//     NFTLevel.OMNIPOTENT: 1024000
// };

contract MintalioNFT is ERC1155 {
    uint256[15] private levelThresholds = [
        //this is here to estimate the level of the NFT
        0, // BRONZE
        100, // SILVER
        250, // GOLD
        500, // PLATINUM
        1000, // DIAMOND
        2000, // LEGENDARY
        4000, // MYTHIC
        8000, // GODLY
        16000, // IMMORTAL
        32000, // DIVINE
        64000, // CELESTIAL
        128000, // COSMIC
        256000, // ETERNAL
        512000, // INFINITE
        1024000 // OMNIPOTENT
    ];

    //errors
    error Not_Contract_Owner();
    error Not_Contract_Admin();
    error Not_NFT_Owner();
    error Not_Enough_Points();
    error Invalid_NFT_Id(uint256 id);
    error Cannot_Remove_Owner();

    //events
    event Mint(address indexed to);
    event AddPoints(uint256 indexed id, uint256 points);
    event WithdrawPoints(uint256 indexed id, uint256 points);
    event TransferNft(
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    event URIChanged(string newURI, uint256 id);

    //TODO: consider: points can be the nfts, if someone owns 1 NFT with id 1 they have 1 point and
    //if someone owns 2 NFTs with id 1 they have 2 points

    address private _owner; // main owner of the contract
    address[] private _admin; // admins of the contract, owner can set admins
    NFT[] private _nfts;

    mapping(uint256 => address) private _nftOwners;
    mapping(uint256 => string) private _nftURIs; // URI of NFT, only visible if set in setURI function

    bytes private dataURI; //URI template

    constructor(string memory _uri) ERC1155(_uri) {
        dataURI = bytes(_uri);
        _owner = msg.sender;
        _admin = new address[](0);
        _admin.push(_owner);
    }

    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert Not_Contract_Owner();
        }
        _;
    }

    modifier onlyAdmin() {
        bool isAdmin = false;

        for (uint i = 0; i < _admin.length; i++) {
            if (msg.sender == _admin[i]) {
                isAdmin = true;
            }
        }

        if (!isAdmin) {
            revert Not_Contract_Admin();
        }
        _;
    }

    function setAdmin(address newAdmin) public onlyOwner {
        _admin.push(newAdmin);
    }

    function removeAdmin(address adminToRemove) public onlyOwner {
        if (adminToRemove == _owner) {
            revert Cannot_Remove_Owner();
        }

        for (uint i = 0; i < _admin.length; i++) {
            if (adminToRemove == _admin[i]) {
                _admin[i] = _admin[_admin.length - 1];
                _admin.pop();
            }
        }
    }

    function mint(address to) public {
        uint256 id = _nfts.length;
        console.log("Minting NFT with id: %d", id);

        _nfts.push(NFT(id, 0, 0, NFTLevel.BRONZE));
        _nftOwners[id] = to;

        _mint(to, id, 1, dataURI);

        emit Mint(to);
    }

    function addPoints(uint256 id, uint256 points) public onlyAdmin {
        if (id < 0 || id > _nfts.length) {
            revert Invalid_NFT_Id(id);
        }

        //update level
        _nfts[id].level = getNFTLevel(_nfts[id].totalPoints + points);

        _nfts[id].points += points;
        _nfts[id].totalPoints += points;

        emit AddPoints(id, points);
    }

    function withdrawPoints(uint256 id, uint256 points) public onlyAdmin {
        if (id < 0 || id > _nfts.length) {
            revert Invalid_NFT_Id(id);
        }

        if (_nfts[id].points < points) {
            revert Not_Enough_Points();
        }

        _nfts[id].points -= points;

        emit WithdrawPoints(id, points);
    }

    function movePoints(uint256 fromId, uint256 toId, uint256 points) public {
        //when users trade points, total points are not increased or decreased
        if (
            fromId < 0 ||
            fromId > _nfts.length ||
            toId < 0 ||
            toId > _nfts.length
        ) {
            revert Invalid_NFT_Id(fromId);
        }

        if (msg.sender != _nftOwners[fromId - 1]) {
            revert Not_NFT_Owner();
        }

        if (_nfts[fromId].points < points) {
            revert Not_Enough_Points();
        }
        //TODO: require owner of fromId to sign this transactions

        _nfts[fromId].points -= points;
        _nfts[toId].points += points;
    }

    function setURI(string memory newURI, uint256 id) public onlyOwner {
        if (id < 0 || id > _nfts.length) {
            revert Invalid_NFT_Id(id);
        }
        _nftURIs[id] = newURI;
        emit URIChanged(newURI, id);
    }

    function nfts(
        uint256 id
    ) public view returns (uint256, uint256, uint256, NFTLevel) {
        if (id < 0 || id > _nfts.length) {
            revert Invalid_NFT_Id(id);
        }

        return (
            _nfts[id].id,
            _nfts[id].points,
            _nfts[id].totalPoints,
            _nfts[id].level
        );
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function admin() public view returns (address[] memory) {
        return _admin;
    }

    function nftOwner(uint256 id) public view returns (address) {
        return _nftOwners[id];
    }

    function get_points(uint256 id) public view returns (uint256) {
        if (id < 0 || id > _nfts.length) {
            revert Invalid_NFT_Id(id);
        }
        return _nfts[id].points;
    }

    function get_total_points(uint256 id) public view returns (uint256) {
        if (id < 0 || id > _nfts.length) {
            revert Invalid_NFT_Id(id);
        }
        return _nfts[id].totalPoints;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        if (tokenId < 0 || tokenId > _nfts.length) {
            revert Invalid_NFT_Id(tokenId);
        }
        if (bytes(_nftURIs[tokenId]).length > 0) {
            return _nftURIs[tokenId];
        }
        return super.uri(tokenId);
    }

    function balanceOf(
        address account,
        uint256 id
    ) public view override returns (uint256) {
        if (id < 0 || id > _nfts.length) {
            revert Invalid_NFT_Id(id);
        }

        return super.balanceOf(account, id);
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

        emit TransferNft(from, to, id, amount);
    }

    function getNFTLevel(uint256 totalPoints) private view returns (NFTLevel) {
        for (uint256 i = 14; i > 0; i--) {
            if (totalPoints >= levelThresholds[i]) {
                return NFTLevel(i);
            }
        }
        return NFTLevel.BRONZE;
    }
}
