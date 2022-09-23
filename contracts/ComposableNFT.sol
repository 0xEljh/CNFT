// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

// @title Composable NFT that can contain child NFTs.
// @author 0xEljh
// @dev Support adding NFTs to this NFT.
abstract contract ComposableNFT is ERC721Burnable, IERC721Receiver {
    struct ChildNFT {
        address contractAddress;
        uint256 tokenId;
    }

    mapping(uint256 => ChildNFT[]) public _childNFTs; // NFT ID => Child NFTs
    mapping(address => ChildNFT[]) public _receivedNFTs; // original owner => Unassigned Child NFTs

    event ChildNFTAdded(
        address indexed contractAddress,
        uint256 indexed tokenId,
        uint256 indexed childTokenId
    );

    constructor() {}

    // @dev safeTransferFrom must be used to add NFTs to the contract.
    // @dev NFTs added this way can then be assigned by the wallet
    // @dev to desired composable NFT.
    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        _receivedNFTs[from].push(ChildNFT(msg.sender, tokenId));
        return this.onERC721Received.selector;
    }

    // @dev return child NFT to the owner of this NFT.
    // @dev this does not delete the array element.
    // Deletion can be handled by the function caller in a more efficient way.
    function _returnChildNFT(ChildNFT[] storage childNFTs, uint256 childIndex)
        internal
    {
        IERC721(childNFTs[childIndex].contractAddress).safeTransferFrom(
            address(this),
            _msgSender(), // TODO: verify if problematic
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

        require(_receivedNFTs[_msgSender()].length > 0, "No NFTs received");

        for (uint256 i = 0; i < _receivedNFTs[_msgSender()].length; i++) {
            if (
                _receivedNFTs[_msgSender()][i].tokenId == childTokenId &&
                _receivedNFTs[_msgSender()][i].contractAddress ==
                contractAddress
            ) {
                // add childNFT to parent NFT.
                _childNFTs[tokenId].push(
                    ChildNFT(contractAddress, childTokenId)
                );

                // remove childNFT from received NFTs.
                _receivedNFTs[_msgSender()][i] = _receivedNFTs[_msgSender()][
                    _receivedNFTs[_msgSender()].length - 1
                ];
                _receivedNFTs[_msgSender()].pop();

                emit ChildNFTAdded(contractAddress, tokenId, childTokenId);
                break;
            }
        }
    }

    function getSentNFTs(address owner)
        external
        view
        returns (ChildNFT[] memory)
    {
        return _receivedNFTs[owner];
    }

    function getChildNFTs(uint256 tokenId)
        external
        view
        returns (ChildNFT[] memory)
    {
        return _childNFTs[tokenId];
    }
}
