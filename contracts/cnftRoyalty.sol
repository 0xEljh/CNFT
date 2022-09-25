// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ComposableNFTRoyalty.sol";

contract cnftRoyalty is ComposableNFTRoyalty {
    constructor() ERC721("cnftRoyalty", "cnftRoyalty") {}

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
        _setTokenRoyalty(tokenId, to, 1000); // 10% royalty
    }
}
