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

    ///@dev 
    function test_ErrorTokenDoesNotExistByGetTierId() public {
        vm.expectRevert(TokenDoesNotExist.selector);
        // Get Tier ID from non-existent token ID
        simpleERC721T.getTierId(0);
    }

    function test_ErrorTokenDoesNotExistByTokenURI() public {
        vm.expectRevert(TokenDoesNotExist.selector);
        // Get token URI from non-existent token ID
        simpleERC721T.tokenURI(0);
    }

    function test_ErrorTierDoesNotExistByGetTierURI() public {
        vm.expectRevert(TierDoesNotExist.selector);
        // Call non-existent tier URI
        simpleERC721T.getTierURI(1);
    }

    function test_ErrorTierDoesNotExistByMint() public {
        vm.expectRevert(TierDoesNotExist.selector);
        // Mint one token ID from non-exixtent tier ID
        simpleERC721T.mint(address(this), 1);
    }

    function test_ErrorURICanNotBeEmpyString() public {
        vm.expectRevert(URICanNotBeEmptyString.selector);
        // Sets tier URI as an empty string
        simpleERC721T.setTierURI(1,"");
    }

    function test_ErrorArrayLengthsMismatch() public {
        simpleERC721T.setTierURI(1,"ipfs://foo");

        // Three receiver addresses
        address[] memory receivers = new address[](3);
        receivers[0] = address(123);
        receivers[1] = address(456);
        receivers[2] = address(789);
        simpleERC721T.airdrop(receivers,1);

        // Two minted token IDs
        uint256[] memory mintedTokenIds = new uint256[](2);
        mintedTokenIds[0] = 0;
        mintedTokenIds[1] = 1;

        vm.expectRevert(ArrayLengthsMismatch.selector);
        simpleERC721T.batchBurn(receivers, mintedTokenIds);
    }
}