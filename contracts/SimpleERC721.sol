// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract SimpleERC721 is ERC721Burnable {
    struct nft {
        address contractAddress;
        uint256 tokenId;
    }

    mapping(address => nft[]) public _nfts;

    constructor() ERC721("NFT", "NFT") {}

    event Returned(address indexed contractAddress, uint256 indexed tokenId);

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        _nfts[from].push(nft(msg.sender, tokenId));
        return this.onERC721Received.selector;
    }

    function checkSentNFTs() public view returns (nft[] memory) {
        return _nfts[msg.sender];
    }

    function returnNFT(address contractAddress, uint256 tokenId) public {
        nft[] storage nfts = _nfts[msg.sender];
        require(nfts.length > 0, "No NFTs to return");

        for (uint256 i = 0; i < nfts.length; i++) {
            if (
                nfts[i].contractAddress == contractAddress &&
                nfts[i].tokenId == tokenId
            ) {
                IERC721(contractAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    tokenId
                );
                emit Returned(contractAddress, tokenId);
                delete nfts[i];
            }
        }
    }

    // rework recieving NFTs:
    // attribute NFTs to the sender via IERC721 receiver interface
    // then allow them to be added
}
