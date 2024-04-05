// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC721} from "@solady/tokens/ERC721.sol";

abstract contract ERC721T is ERC721 {
    /// @dev The tier ID does not exist.
    error TierDoesNotExist();

    /// @dev The URI can not be empty string.
    error URICanNotBeEmptyString();


    /// @dev Emitted when `tokenId` is minted and mapped to `tierId`.
    event TierMinted (uint256 indexed tokenId, uint256 indexed tierId);

    /// @dev Emitted when `tokenId` is burned and unmapped from `tierId`.
    event TierBurned (uint256 indexed tokenId, uint256 indexed tierId);

    /// @dev Emitted when `tierURI` is set and mapped to `tier`.
    event TierURI (string tierURI, uint256 indexed tier);


    /// @dev The next token ID to be minted.
    uint256 private _currentIndex;

    /// @dev The number of tokens burned.
    uint256 private _burnCounter;

    /// @dev Token name.
    string private _name;

    /// @dev Token symbol.
    string private _symbol;

    /// @dev Mapping from token ID to tier ID.
    mapping (uint256 => uint256) internal _tierId;

    /// @dev Mapping from tier ID to tier URI.
    mapping (uint256 => string) internal _tierURI;


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    /// @dev Returns the token collection name.
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /// @dev Returns the token collection symbol.
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /// @dev See {ERC721 - tokenURI}.
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert TokenDoesNotExist();
        uint256 tierId = _tierId[tokenId];
        string memory tierURI = _tierURI[tierId];
        return tierURI;
    }

    /// @dev Returns the total number of tokens in existence.
    function totalSupply() public view virtual returns (uint256) {
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    /// @dev Returns the starting token ID for sequential mints.
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /// @dev Returns the next token ID to be minted.
    function _nextTokenId() internal view virtual returns (uint256) {
        return _currentIndex;
    }

    /// @dev Returns the total number of tokens burned.
    function _totalBurned() internal view virtual returns (uint256) {
        return _burnCounter;
    }

    /// @dev Mints single quantity of token ID  to `to` and map it to `tierid`.
    function _mintTier(address to, uint256 tierId) internal virtual {
        if (bytes(_tierURI[tierId]).length == 0) revert TierDoesNotExist();
        uint256 _tokenId = _nextTokenId();
        _tierId[_tokenId] = tierId;
        unchecked {
            ++_currentIndex;
        }
        _mint(to, _tokenId);

        emit TierMinted(_tokenId, tierId);
    }

    /// @dev Burns single quantity of `tokenId` from `owner` and unmap it from its tier ID.
    function _burnTier(address owner, uint256 tokenId) internal virtual {
        uint256 tierId_ = _tierId[tokenId];
        delete _tierId[tokenId];
        unchecked {
            ++_burnCounter;
        }
        _burn(owner, tokenId);

        emit TierBurned(tokenId, tierId_);
    }

    /// @dev Sets 'tierURI' as the tier URI of 'tierId'.
    function _setTierURI(uint256 tierId, string memory tierURI) internal virtual {
        if (bytes(tierURI).length == 0) revert URICanNotBeEmptyString();
        _tierURI[tierId] = tierURI;

        emit TierURI(tierURI, tierId);
    }
}