// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SampleERC721T} from "src/examples/SampleERC721T.sol";

contract SampleERC721TTest is Test {
    SampleERC721T sampleERC721T;

    uint256 constant CURRENT_BLOCKTIMESTAMP = 1737667200; // January 23, 2025, 9:20 PM UTC
    uint56 constant MAX_TIER_ID = 0xFFFFFFFFFFFFFF; // 72057594037927935

    address constant MINTER_OR_BURNER = 0xcfd86e16635486b2eCAf674A98F24ed12a15c3b4;
    address constant BAD_ACTOR = 0xac912225f59d840c700cc9F04CD5Ade96Bd009BF;
    address constant AIRDROP_RECIPIENT_INDEX_ZERO = 0xa74A9c716F60C7362a3909ca47E6362777C7EbcA;
    address constant AIRDROP_RECIPIENT_INDEX_ONE = 0x364D1F67f71d976A317F65cD64Ebc1E6C48a14AA;
    address constant AIRDROP_RECIPIENT_INDEX_TWO = 0x4754393f17E07ACB5984a5CFF8fa29c294c76FbC;

    address contractOwner;

    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event TierSet(uint256 indexed fromTokenId, uint256 indexed quantity, uint56 indexed tierId, uint256 atTimestamp);
    event TierReset(uint256 indexed tokenId, uint56 indexed tierId);

    error NotOwnerNorApproved();
    error TokenDoesNotExist();
    error Unauthorized();
    error TierCanNotBeZero();

    function setUp() external {
        sampleERC721T = new SampleERC721T();
        contractOwner = address(sampleERC721T.owner());
    }

    /// Public view functions ///

    function test_Name() public view {
        assertEq(sampleERC721T.name(),"Sample ERC721T");
    }

    function test_Symbol() public view {
        assertEq(sampleERC721T.symbol(),"S721T");
    }

    function test_TokenURI() public {
        sampleERC721T.mintTier(MINTER_OR_BURNER, 1); // _mintTier
        assertEq(sampleERC721T.tokenURI(0),"ipfs://foobar/1/0"); // tokenId #0; tierId #1
        sampleERC721T.safeMintTier(MINTER_OR_BURNER, 2); // _safeMintTier
        assertEq(sampleERC721T.tokenURI(1),"ipfs://foobar/2/1"); // tokenId #1; tierId #2
    }

    function test_TokenURI_ForNonExistentTokenId() public {
        vm.expectRevert(TokenDoesNotExist.selector);
        sampleERC721T.tokenURI(0);
    }

    function test_TierId() public {
        sampleERC721T.mintTier(MINTER_OR_BURNER, 69);
        assertEq(sampleERC721T.tierId(0), 69); // tokenId #0; tierId #69
    }

    function test_TierId_ForNonExistentTokenId() public view {
        assertEq(sampleERC721T.tierId(0), 0);
    }

    function test_MintTimestamp() public {
        vm.warp(CURRENT_BLOCKTIMESTAMP);
        sampleERC721T.mintTier(MINTER_OR_BURNER, 420);
        assertEq(sampleERC721T.mintTimestamp(0), CURRENT_BLOCKTIMESTAMP);
    }

    function test_MintTimestamp_ForNonExistentTokenId() public view {
        assertEq(sampleERC721T.mintTimestamp(0), 0);
    }

    function test_TotalSupply_AfterSingleTokenMinted() public {
        assertEq(sampleERC721T.totalSupply(), 0); // Before mint
        _mintTierSingleToken();
        assertEq(sampleERC721T.totalSupply(), 1); // After mint
    }

    function test_TotalSupply_AfterSingleTokenBurned() public {
        _mintTierSingleToken();
        assertEq(sampleERC721T.totalSupply(), 1); // Before burn
        vm.prank(MINTER_OR_BURNER);
        sampleERC721T.burnTierBy(MINTER_OR_BURNER, 0);
        assertEq(sampleERC721T.totalSupply(), 0); // After burn
    }

    /// Mint functions ////

    function test_MintTier() public {
        vm.prank(MINTER_OR_BURNER);
        vm.warp(CURRENT_BLOCKTIMESTAMP);
        vm.expectEmit();
        emit Transfer(address(0), MINTER_OR_BURNER, 0); // Token ID starts from zero
        emit TierSet(0, 1, 1, CURRENT_BLOCKTIMESTAMP);
        sampleERC721T.mintTier(MINTER_OR_BURNER, 1);
    }

    function test_SafeMintTier() public {
        vm.warp(CURRENT_BLOCKTIMESTAMP);
        vm.prank(MINTER_OR_BURNER);
        vm.expectEmit();
        emit Transfer(address(0), MINTER_OR_BURNER, 0);
        emit TierSet(0, 1, 1, CURRENT_BLOCKTIMESTAMP);
        sampleERC721T.safeMintTier(MINTER_OR_BURNER, 1);
    }

    function test_BatchMintTier() public {
        vm.warp(CURRENT_BLOCKTIMESTAMP);
        vm.prank(MINTER_OR_BURNER);
        vm.expectEmit();
        emit Transfer(address(0), MINTER_OR_BURNER, 0);
        emit Transfer(address(0), MINTER_OR_BURNER, 1);
        emit Transfer(address(0), MINTER_OR_BURNER, 2);
        emit TierSet(0, 3, 1, CURRENT_BLOCKTIMESTAMP);
        sampleERC721T.batchMintTier(MINTER_OR_BURNER, 1, 3);
    }

    function test_BatchSafeMintTier() public {
        vm.warp(CURRENT_BLOCKTIMESTAMP);
        vm.prank(address(MINTER_OR_BURNER));
        vm.expectEmit();
        emit Transfer(address(0), MINTER_OR_BURNER, 0);
        emit Transfer(address(0), MINTER_OR_BURNER, 1);
        emit Transfer(address(0), MINTER_OR_BURNER, 2);
        emit TierSet(0, 3, 1, CURRENT_BLOCKTIMESTAMP);
        sampleERC721T.batchSafeMintTier(MINTER_OR_BURNER, 1, 3);
    }

    function test_AirdropTier_ByContractOwner() public {
        address[] memory recipients = new address[](3);
        recipients[0] = AIRDROP_RECIPIENT_INDEX_ZERO;
        recipients[1] = AIRDROP_RECIPIENT_INDEX_ONE;
        recipients[2] = AIRDROP_RECIPIENT_INDEX_TWO;

        vm.warp(CURRENT_BLOCKTIMESTAMP);

        vm.prank(contractOwner);
        vm.expectEmit();
        emit Transfer(address(0), AIRDROP_RECIPIENT_INDEX_ZERO, 0);
        emit Transfer(address(0), AIRDROP_RECIPIENT_INDEX_ONE, 1);
        emit Transfer(address(0), AIRDROP_RECIPIENT_INDEX_TWO, 2);
        emit TierSet(0, 1, 1, CURRENT_BLOCKTIMESTAMP);
        emit TierSet(1, 1, 1, CURRENT_BLOCKTIMESTAMP);
        emit TierSet(2, 1, 1, CURRENT_BLOCKTIMESTAMP);
        sampleERC721T.airdropTier(recipients, 1);
    }

    function test_RevertWhen_MintTier_TierIdIsZero() public {
        vm.prank(MINTER_OR_BURNER);
        vm.expectRevert(TierCanNotBeZero.selector);
        sampleERC721T.mintTier(MINTER_OR_BURNER, 0);
    }

    function test_RevertWhen_MintTier_TierIdExceedsMaxUint56Value() public {
        vm.prank(MINTER_OR_BURNER);
        vm.expectRevert(); // panic: arithmetic underflow or overflow (0x11)
        sampleERC721T.mintTier(MINTER_OR_BURNER, MAX_TIER_ID + 1);
    }

    function test_RevertWhen_AirdropTier_ByNonContractOwner() public {
        address[] memory recipients = new address[](3);
        recipients[0] = AIRDROP_RECIPIENT_INDEX_ZERO;
        recipients[1] = AIRDROP_RECIPIENT_INDEX_ONE;
        recipients[2] = AIRDROP_RECIPIENT_INDEX_TWO;

        vm.prank(BAD_ACTOR);
        vm.expectRevert(Unauthorized.selector);
        sampleERC721T.airdropTier(recipients, 1);
    }

    /// Burn functions ///

    function test_BurnTier_ByContractOwner() public {
        _mintTierSingleToken();
        
        vm.prank(contractOwner);
        vm.expectEmit();
        emit Transfer(MINTER_OR_BURNER, address(0), 0);
        emit TierReset(0, 1);
        sampleERC721T.burnTier(0);
    }

    function test_BurnTier_ByTokenOwner() public {
        _mintTierSingleToken();
        
        vm.prank(MINTER_OR_BURNER);
        vm.expectEmit();
        emit Transfer(MINTER_OR_BURNER, address(0), 0);
        emit TierReset(0, 1);
        sampleERC721T.burnTierBy(MINTER_OR_BURNER, 0);
    }

    function test_RevertWhen_BurnTier_ByNonTokenOwner() public {
        _mintTierSingleToken();
        
        vm.prank(BAD_ACTOR);
        vm.expectRevert(NotOwnerNorApproved.selector);
        sampleERC721T.burnTierBy(BAD_ACTOR, 0);
    }

    function test_RevertWhen_BurnTier_ByNonContractOwner() public {
        _mintTierSingleToken();
        
        vm.prank(BAD_ACTOR);
        vm.expectRevert(Unauthorized.selector);
        sampleERC721T.burnTier(0);
    }

    /// Internal setup ///

    function _mintTierSingleToken() internal {
        vm.prank(MINTER_OR_BURNER);
        sampleERC721T.mintTier(MINTER_OR_BURNER, 1);
    }
}