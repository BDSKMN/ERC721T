// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721T} from "src/ERC721T.sol";
import {Ownable} from "lib/solady/src/auth/Ownable.sol";

contract SampleERC721T is ERC721T, Ownable {
    constructor() ERC721T("Sample ERC721T", "S721T") {
        _initializeOwner(msg.sender);
    }

    function mintTier(address to, uint56 tierId) public {
        _mintTier(to, tierId);
    }

    function safeMintTier(address to, uint56 tierId) public {
        _safeMintTier(to, tierId);
    }

    function batchMintTier(address to, uint56 tierId, uint256 quantity) public {
        _batchMintTier(to, tierId, quantity);
    }

    function batchSafeMintTier(address to, uint56 tierId, uint256 quantity) public {
        _batchSafeMintTier(to, tierId, quantity);
    }

    function burnTierBy(address owner, uint256 tokenId) public {
        _burnTier(owner, tokenId);
    }

    function airdropTier(address[] calldata recipients, uint56 tierId) public onlyOwner {
        for (uint256 i = 0; i < recipients.length;) {
            _mintTier(recipients[i], tierId);
            unchecked { ++i; }   
        }
    }

    function burnTier(uint256 tokenId) public onlyOwner {
        _burnTier(tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) _rv(uint32(TokenDoesNotExist.selector));
        uint256 tierId = uint256(tierId(tokenId));
        return string(
            abi.encodePacked("ipfs://foobar/", _toString(tierId), "/", _toString(tokenId))
        );
    }
}