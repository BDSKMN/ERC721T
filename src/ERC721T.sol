// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC721} from "@solady/tokens/ERC721.sol";

/// @title ERC721T
/// @author 0xkuwabatake
/// @notice A contract extension to create a tier-based ERC721 NFT collection.
/// @dev Note:
/// - The contract is an abstract contract that inherit to Simple ERC721 implementation by Solady
///   (https://github.com/vectorized/solady/blob/main/src/tokens/ERC721.sol).
/// - The contract is intended to be used as base contract by child (implementation) contract.
/// - Token IDs are minted in sequential order (e.g. 0, 1, 2, 3, ...) starting from `_startTokenId()`,
///   but this extension DOES NOT provide the batch creation of token IDs mechanism.
/// - Tier ID is a generic identifier to map some minted token IDs to return similar token URI value.
///   This identifier is created when a child contract call `_setTierURI` method, with its parameters:
///   - `tierId` is an arbitrary uint256 value. If not exist, it will create a new tier ID. If exist,
///      the intention is to change the existing `tierURI` corresponds to its `tierId`.
///   - `tierURI` MUST NOT an empty string to differentiate it from non-existent tier URI. 
///      This implementation won't check if the URI follows the ERC721 Metadata JSON schema or not, 
///      responsibility is delegated to the caller.
///
/// If you are overriding:
/// - MAKE SURE to not violate the creation of non-empty string tier URI before token ID creation.
///   It can be achieved by NOT REMOVING `if (bytes(_tierURI[tierId]).length == 0) revert TierDoesNotExist();`
///   checker before call _mint(to, tokenId) from ERC721 contract.
abstract contract ERC721T is ERC721 {
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

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

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @dev Emitted when `tokenId` is minted and mapped to `tierId`.
    event TierMinted (uint256 indexed tokenId, uint256 indexed tierId);

    /// @dev Emitted when `tokenId` is burned and unmapped from `tierId`.
    event TierBurned (uint256 indexed tokenId, uint256 indexed tierId);

    /// @dev Emitted when `tierURI` is set and mapped to `tier`.
    event TierURI (string tierURI, uint256 indexed tier);

    /*//////////////////////////////////////////////////////////////
                            CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev The tier ID does not exist.
    error TierDoesNotExist();

    /// @dev The URI can not be empty string.
    error URICanNotBeEmptyString();

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns the token collection name.
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /// @dev Returns the token collection symbol.
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /// @dev Returns tier ID from `tokenId`.
    function getTierId(uint256 tokenId) public view virtual returns (uint256) {
        if (!_exists(tokenId)) _revert(TokenDoesNotExist.selector);
        return _tierId[tokenId];
    }

    /// @dev Returns tier URI from `tierId`.
    function getTierURI(uint256 tierId) public view virtual returns (string memory) {
        if (bytes(_tierURI[tierId]).length == 0) _revert(TierDoesNotExist.selector);
        return _tierURI[tierId];
    }

    /// @dev See {ERC721 - tokenURI}.
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) _revert(TokenDoesNotExist.selector);
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

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev Mints single quantity of token ID  to `to` and map it to `tierid`.
    /// @param to cannot be the zero address.
    /// @param tierId must exist. It exists if the corresponding tier URI is not an empty string.
    function _mintTier(address to, uint256 tierId) internal virtual {
        if (bytes(_tierURI[tierId]).length == 0) _revert(TierDoesNotExist.selector);
        uint256 _tokenId = _nextTokenId();
        _tierId[_tokenId] = tierId;
        unchecked {
            ++_currentIndex;
        }
        _mint(to, _tokenId);

        emit TierMinted(_tokenId, tierId);
    }

    /// @dev Burns single quantity of `tokenId` from `owner` and unmap it from its tier ID.
    /// @param owner is the owner of the existing `tokenId`.
    /// @param tokenId must exist.
    function _burnTier(address owner, uint256 tokenId) internal virtual {
        uint256 tierId_ = _tierId[tokenId];
        delete _tierId[tokenId];
        unchecked {
            ++_burnCounter;
        }
        _burn(owner, tokenId);

        emit TierBurned(tokenId, tierId_);
    }

    /// @dev Sets 'tierURI' as the URI of 'tierId'.
    /// @param tierId is an arbitrary uint256 value as tier ID.
    /// @param tierURI MUST NOT an empty string to differentiate it from non-existent tier URI.
    function _setTierURI(uint256 tierId, string memory tierURI) internal virtual {
        if (bytes(tierURI).length == 0) _revert(URICanNotBeEmptyString.selector);
        _tierURI[tierId] = tierURI;

        emit TierURI(tierURI, tierId);
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

    /// @dev For more efficient reverts.
    function _revert(bytes4 errorSelector) internal pure {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }
}