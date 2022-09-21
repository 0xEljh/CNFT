// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

// @title Composable NFT that can contain child NFTs.
// @author 0xEljh
// @dev Support adding NFTs to this NFT.
abstract contract ComposableNFT is ERC721Burnable {
    struct ChildNFT {
        address contractAddress;
        uint256 tokenId;
    }

    mapping(uint256 => ChildNFT[]) public _childNFTs;

    constructor() {}

    // @dev return child NFT to the owner of this NFT.
    // @dev this does not delete the array element.
    // Deletion can be handled by the function caller in a more efficient way.
    function _returnChildNFT(ChildNFT[] storage childNFTs, uint256 childIndex)
        internal
    {
        IERC721(childNFTs[childIndex].contractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            childNFTs[childIndex].tokenId
        );
    }

    // @dev burn token and also return all child NFTs to the owner.
    // this prevents child NFTs from being lost to this contract.
    // hence burn is effectively a decomposition.
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        ChildNFT[] storage childNFTs = _childNFTs[tokenId];
        // return all child NFTs to the owner
        for (uint256 i = 0; i < childNFTs.length; i++) {
            _returnChildNFT(childNFTs, i);
        }
        // delete child NFT mapping
        delete _childNFTs[tokenId];
    }

    // function decompose(uint256 tokenId) public virtual {
    //     require(
    //         _isApprovedOrOwner(_msgSender(), tokenId),
    //         "ComposableNFT: caller is not token owner nor approved"
    //     );
    //     // burn this NFT; it also returns all child NFTs to the owner
    //     _burn(tokenId);
    // }

    // @dev Remove a specific child NFT from this NFT.
    // @param tokenId The ID of the NFT to remove.
    // @param contractAddress The address of the NFT to remove.
    // @param childTokenId The ID of the child NFT to remove.
    function removeChildNFT(
        uint256 tokenId,
        address contractAddress,
        uint256 childTokenId
    ) external virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ComposableNFT: caller is not token owner nor approved"
        );

        ChildNFT[] storage childNFTs = _childNFTs[tokenId];

        for (uint256 i = 0; i < childNFTs.length; i++) {
            if (
                childNFTs[i].tokenId == childTokenId &&
                childNFTs[i].contractAddress == contractAddress
            ) {
                _returnChildNFT(childNFTs, i);
                // Remove the child NFT from the array.
                childNFTs[i] = childNFTs[childNFTs.length - 1];
                childNFTs.pop();
                break;
            }
        }

        // burn this NFT if it has no child NFTs
        if (childNFTs.length == 0) {
            _burn(tokenId);
        }
    }

    function _recieveNFT(address contractAddress, uint256 tokenId) internal {
        IERC721(contractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        // verify NFT is now owned by contract
        require(
            IERC721(contractAddress).ownerOf(tokenId) == address(this),
            "ComposableNFT: recieve NFT failed"
        );
    }

    // @dev Add a child NFT to this NFT by transferring it to this contract.
    // @param tokenId The ID of parent NFT
    // @param contractAddress The address of child NFT to add.
    // @param childTokenId The ID of the child NFT to add.
    function addChildNFT(
        uint256 tokenId,
        address contractAddress,
        uint256 childTokenId
    ) external virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ComposableNFT: caller is not token owner nor approved"
        );
        _recieveNFT(contractAddress, childTokenId);
        _childNFTs[tokenId].push(ChildNFT(contractAddress, childTokenId));
    }

    // // @dev Compose child NFTs by minting a new NFT.
    // // @param childNFTs The array of child NFTs to compose.
    // // @param to The address to mint the new NFT to.
    // // @param uri The URI of the new NFT.
    // function compose(
    //     ChildNFT[] memory childNFTs,
    //     address to,
    //     string memory uri
    // ) public virtual {
    //     // generate a new token ID
    //     // TODO: use a better way to generate token ID
    //     uint256 tokenId = uint256(keccak256(abi.encode(childNFTs)));
    //     // mint the new NFT
    //     _mint(to, tokenId);

    //     for (uint256 i = 0; i < childNFTs.length; i++) {
    //         _recieveNFT(childNFTs[i].contractAddress, childNFTs[i].tokenId);
    //         _childNFTs[tokenId].push(childNFTs[i]);
    //     }
    // }
}
