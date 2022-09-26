# CNFT
Composable NFTs with Royalty Sharing

## Composing NFTs
After mining a Composable NFT (CNFT), more NFTs can be composed by sending them to the CNFT smart contract and adding them as a child to the CNFT.

`getReceivedNFTs(address owner)`
Retrieve ERC721 NFTs that were sent to the smart contract via safeTransferFrom by the owner's address.

`addChildNFT(uint256 tokenId, address contractAddress, uint256 childTokenId)`
Add a ERC721 NFT to a CNFT token by providing its contract address and tokenId, as well as the tokenId of the CNFT. All tokens involved should belong or have been sent by the `msg.sender`.

`getChildNFTs(uint256 tokenId)`
Retrieve child NFTs that the CNFT points to.

## Royalty Splitting
Royalty splitting to CNFT creator and child NFT creators happens automatically when royalties are received by the royalty handler contract.
These contracts are created upon setting the token royalty via `_setTokenRoyalty`

`setValueFraction(uint256 tokenId, uint96[] memory valueFractions)`
Set the value fraction between the child NFTs. Total value fraction should sum up to at most 10,000 by default. Unassigned value fraction gets attributed to the CNFT creator.
