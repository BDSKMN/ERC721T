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

    ///@dev 
    function test_EmitTierURI() public {
        vm.expectEmit();
        emit TierURI("ipfs://bar",42);
        // Sets Tier URI
        simpleERC721T.setTierURI(42,"ipfs://bar");
    }

    function test_EmitTierMintedByMint() public {
        simpleERC721T.setTierURI(1,"ipfs://foo");
        vm.expectEmit();
        // Token ID starts from #0
        emit TierMinted(0,1);
        // Mint one token ID from existing tier ID
        simpleERC721T.mint(address(this),1);
    }

    function test_EmitTierMintedByAirdrop() public {
        simpleERC721T.setTierURI(1,"ipfs://foo");
        
        // Three receiver addresses
        address[] memory receivers = new address[](3);
        receivers[0] = address(123);
        receivers[1] = address(456);
        receivers[2] = address(789);
    
        vm.expectEmit();
        emit TierMinted(0,1);
        emit TierMinted(1,1);
        emit TierMinted(2,1);
        simpleERC721T.airdrop(receivers,1);
    }

    function test_EmitTierBurned() public {
        simpleERC721T.setTierURI(1,"ipfs://foo");
        simpleERC721T.mint(address(this), 1);

        vm.expectEmit();
        // Minted token ID #0
        emit TierBurned(0,1);
        // Burn token ID #0
        simpleERC721T.burn(address(this), 0);
    }

    function test_EmitTierBurnedByBatchBurn() public {
        simpleERC721T.setTierURI(1,"ipfs://foo");
        
        // Three owner addresses
        address[] memory owners = new address[](3);
        owners[0] = address(123);
        owners[1] = address(456);
        owners[2] = address(789);
        simpleERC721T.airdrop(owners,1);

        uint256[] memory mintedTokenIds = new uint256[](3);
        // Three minted token ID starts from #0
        mintedTokenIds[0] = 0;
        mintedTokenIds[1] = 1;
        mintedTokenIds[2] = 2;

        vm.expectEmit();
        emit TierBurned(0,1);
        emit TierBurned(1,1);
        emit TierBurned(2,1);
        // Batch burn three minted token IDs
        simpleERC721T.batchBurn(owners,mintedTokenIds);
    }
}