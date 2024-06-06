// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721T} from "src/ERC721T.sol";
import {Ownable} from "lib/solady/src/auth/Ownable.sol";

contract SimpleERC721T is ERC721T, Ownable {
    error ArrayLengthsMismatch();

    constructor() ERC721T("Simple ERC721T", "S721T") {
        _initializeOwner(msg.sender);
    }

    function mint(address to, uint256 tierId) public {
        _mintTier(to, tierId);
    }

    function airdrop(address[] calldata receivers, uint256 tierId) public onlyOwner {
        for (uint256 i = 0; i < receivers.length;) {
            if (bytes(_tierURI[tierId]).length == 0) revert TierDoesNotExist();
            _mintTier(receivers[i], tierId);
            unchecked { ++i; }   
        }
    }

    function burn(address owner, uint256 tokenId) public {
        _burnTier(owner, tokenId);
    }

    function batchBurn(address[] calldata owners, uint256[] calldata tokenIds) public onlyOwner {
        if (owners.length != tokenIds.length) revert ArrayLengthsMismatch();
        for (uint256 i = 0; i < owners.length;) {
            _burnTier(owners[i], tokenIds[i]);
            unchecked { ++i; }   
        }
    }

    function setTierURI(uint256 tierId, string calldata tierURI) public onlyOwner {
        _setTierURI(tierId, tierURI);
    }
}