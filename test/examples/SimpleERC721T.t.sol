// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

import {SimpleERC721T} from "src/examples/SimpleERC721T.sol";

contract SimpleERC721TTest is Test {
    SimpleERC721T public simpleERC721T;

    error TokenDoesNotExist();
    error TierDoesNotExist();
    error URICanNotBeEmptyString();
    error ArrayLengthsMismatch();

    event TierMinted (uint256 indexed tokenId, uint256 indexed tierId);
    event TierBurned (uint256 indexed tokenId, uint256 indexed tierId);
    event TierURI (string tierURI, uint256 indexed tier);

    function setUp() external {
        simpleERC721T = new SimpleERC721T();
    }
}