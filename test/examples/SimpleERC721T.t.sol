// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

import {SimpleERC721T} from "src/examples/SimpleERC721T.sol";

contract SimpleERC721TTest is Test {
    SimpleERC721T public simpleERC721T;

    function setUp() external {
        simpleERC721T = new SimpleERC721T();
    }
}