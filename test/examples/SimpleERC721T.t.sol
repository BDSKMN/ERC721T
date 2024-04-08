// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

import {SimpleERC721T} from "src/examples/SimpleERC721T.sol";

contract SimpleERC721TTest is Test {
    SimpleERC721T public simpleERC721T;

    error TokenDoesNotExist();
    error Unauthorized();
    error TierDoesNotExist();
    error URICanNotBeEmptyString();
    error ArrayLengthsMismatch();

    event TierMinted (uint256 indexed tokenId, uint256 indexed tierId);
    event TierBurned (uint256 indexed tokenId, uint256 indexed tierId);
    event TierURI (string tierURI, uint256 indexed tier);

    function setUp() external {
        simpleERC721T = new SimpleERC721T();
    }

    ///@dev Getter Functions
    function test_GetValueFrom_Name() public view {
        assertEq(simpleERC721T.name(),"Simple ERC721T");
    }

    function test_GetValueFrom_Symbol() public view {
        assertEq(simpleERC721T.symbol(),"S721T");
    }

    function test_GetValueFrom_TokenURI() public {
        simpleERC721T.setTierURI(1,"ipfs://foo");
        simpleERC721T.mint(address(this), 1);
        // Minted token ID #0
        assertEq(simpleERC721T.tokenURI(0),"ipfs://foo");
    }

    function test_RevertWhen_GetTokenURIFrom_NonExistentTokenId() public {
        vm.expectRevert(TokenDoesNotExist.selector);
        simpleERC721T.tokenURI(0);
    }

    function test_GetValueFrom_GetTierId() public {
        simpleERC721T.setTierURI(69,"ipfs://bar");
        simpleERC721T.mint(address(this), 69);
        // Minted token ID #0
        assertEq(simpleERC721T.getTierId(0), 69);
    }

    function test_RevertWhen_GetTierIdFrom_NonExistentTokenId() public {
        vm.expectRevert(TokenDoesNotExist.selector);
        simpleERC721T.getTierId(0);
    }

    function test_GetValueFrom_GetTierURI() public {
        simpleERC721T.setTierURI(1,"ipfs://foo");
        assertEq(simpleERC721T.getTierURI(1),"ipfs://foo");
    }

    function test_RevertWhen_GetTierURIFrom_NonExistentTierURI() public {
        vm.expectRevert(TierDoesNotExist.selector);
        simpleERC721T.getTierURI(1);
    }

    function test_GetValueFrom_TotalSupplyAfter_Mint() public {
        simpleERC721T.setTierURI(1,"ipfs://foo");
        simpleERC721T.mint(address(this), 1);
        // Total supply plus 1
        assertEq(simpleERC721T.totalSupply(), 1);
    }

    function test_GetValueFrom_TotalSupplyAfter_Burn() public {
        simpleERC721T.setTierURI(1,"ipfs://foo");
        simpleERC721T.mint(address(this), 1);
        // Minted token ID #0
        simpleERC721T.burn(address(this), 0);
        // Total supply back to 0
        assertEq(simpleERC721T.totalSupply(), 0);
    }

    ///@dev Setter function
    function test_ExpectEmitTierURIBy_SetTierURI() public {
        vm.expectEmit();
        emit TierURI("ipfs://foo",1);
        simpleERC721T.setTierURI(1,"ipfs://foo");
    }

    function test_RevertWhen_SetTierURIWith_EmptyString() public {
        vm.expectRevert(URICanNotBeEmptyString.selector);
        simpleERC721T.setTierURI(1,"");
    }

    function test_RevertIf_SetTierURICallerIsNotOwner() public {
        vm.prank(address(0));
        vm.expectRevert(Unauthorized.selector);
        simpleERC721T.setTierURI(1,"ipfs://foo");
    }

    ///@dev Mint & airdrop functios
    function test_ExpectEmitTierMintedBy_Mint() public {
        simpleERC721T.setTierURI(1,"ipfs://foo");
        vm.expectEmit();
        // Token ID starts from #0
        emit TierMinted(0,1);
        simpleERC721T.mint(address(this),1);
    }

    function test_RevertWhen_MintFrom_NonExistentTierId() public {
        vm.expectRevert(TierDoesNotExist.selector);
        simpleERC721T.mint(address(this), 1);
    }

    function test_ExpectEmitTierMintedBy_AirdropThreeTokenIds() public {
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

    function test_RevertIf_AirdropCallerIsNotOwner() public {
        simpleERC721T.setTierURI(1,"ipfs://foo");
        
        // Three receiver addresses
        address[] memory receivers = new address[](3);
        receivers[0] = address(123);
        receivers[1] = address(456);
        receivers[2] = address(789);

        vm.prank(address(0));
        vm.expectRevert(Unauthorized.selector);
        simpleERC721T.airdrop(receivers, 1);
    }

    ///@dev Burn & batch burn functions
    function test_ExpectEmitTierBurnedBy_Burn() public {
        simpleERC721T.setTierURI(1,"ipfs://foo");
        simpleERC721T.mint(address(this), 1);

        vm.expectEmit();
        // Minted token ID #0
        emit TierBurned(0,1);
        simpleERC721T.burn(address(this), 0);
    }

    function test_ExpectEmitTierBurnedBy_BatchBurnThreeTokenIds() public {
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
        simpleERC721T.batchBurn(owners,mintedTokenIds);
    }

    function test_RevertWhen_BatchBurnFrom_MismatchArrayLengthsOfArguments() public {
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

    function test_RevertIf_BatchBurnCallerIsNotOwner() public {
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

        vm.prank(address(0));
        vm.expectRevert(Unauthorized.selector);
        simpleERC721T.batchBurn(owners, mintedTokenIds);
    }
}