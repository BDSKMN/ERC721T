# ERC721T

## About
ERC721T extends[Solady’s ERC721](https://github.com/Vectorized/solady/blob/main/src/tokens/ERC721.sol) by leveraging the 96-bit extra data (via [`_setExtraData`](https://github.com/Vectorized/solady/blob/main/src/tokens/ERC721.sol#L424)) to map token IDs to tier IDs, enabling tier-based NFT collections with efficient on-chain storage.

## Use Cases
1. Tier-Based Membership NFTs (e.g., Gold, Silver, Bronze memberships)
2. Ticketing Systems (e.g., Multi-Day Event Passes, Seat Categories)
3. Dynamic Rarity Collections (e.g., Limited Edition vs. Open Edition NFTs)
4. POAPs with Multiple Categories (e.g., Attendance-Based Badges) 

## How It Works
1.	Tier ID is assigned on mint, stored via extra data in Solady’s ERC721.
	  - Tier ID cannot be zero, as zero is the default value for non-minted tokens.
	  - When a token is burned, its tier ID resets to zero, ensuring no ambiguity in existence.
2.	Minting follows a sequential ID model, which is ideal for NFT collections, maintaining a structured token distribution.
3.	Supports batch minting, allowing multiple tokens to be assigned the same Tier ID in one transaction.

## Example Implementation
Check out the [SampleERC721T](https://github.com/0xkuwabatake/ERC721T/blob/main/src/examples/SampleERC721T.sol) contract for a practical implementation.

## Disclaimer

This contract is unaudited and provided as is, without warranties. Use at your own risk. Always conduct thorough testing before deploying in production.