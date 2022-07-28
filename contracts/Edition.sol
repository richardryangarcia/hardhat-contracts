// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Edition is ERC721, IERC2981, Ownable {
    using Counters for Counters.Counter;

    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _royalties;

    Counters.Counter private _tokenIdCount;

    bytes32 public merkleRoot;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    function mint() external payable {}

    function presaleMint(bytes32[] calldata _proof) external payable {
        require(
            MerkleProof.verify(
                _proof,
                merkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Address not in accepted list"
        );
        uint256 tokenId = _tokenIdCount.current();
        _safeMint(msg.sender, tokenId);
        _tokenIdCount.increment();
    }

    function setMerkleRoot(bytes32 _merkleRoot) public {
        merkleRoot = _merkleRoot;
    }

    function getCurrentCounter() public view returns (uint256) {
        return _tokenIdCount.current();
    }

    function _setRoyalties(address recipient, uint256 value) internal {
        require(value <= 10000, "Royalty Fraction Too high");
        _royalties = RoyaltyInfo(recipient, uint24(value));
    }

    function royaltyInfo(uint256, uint256 _salePrice)
        public
        view
        virtual
        override
        returns (address, uint256)
    {
        RoyaltyInfo memory royalty = _royalties;

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / 10000;

        return (royalty.receiver, royaltyAmount);
    }
}
