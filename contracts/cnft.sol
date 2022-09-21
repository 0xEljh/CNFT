// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ComposableNFT.sol";

contract cnft is ComposableNFT {
    constructor() ERC721("cnft", "cnft") {}

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
}
