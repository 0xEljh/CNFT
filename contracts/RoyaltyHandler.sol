// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

using SafeMath for uint256;

struct ChildNFT {
    address contractAddress;
    uint256 tokenId;
}

interface ComposableNFTRoyaltyInterface {
    function getChildNFTs(uint256 tokenId)
        external
        view
        returns (ChildNFT[] memory);
}

contract RoyaltyHandler {
    address payable private royaltyReceiver;
    address payable composableNFTContract;
    uint256 tokenId;

    event RoyaltyPayout(
        address indexed receiver,
        uint256 indexed tokenId,
        uint256 amount
    );

    constructor(
        address payable _royaltyReceiver,
        address _composableNFTContract,
        uint256 _tokenId
    ) {
        royaltyReceiver = _royaltyReceiver;
        // made payable to aid with contract creation in ComposableNFTRoyalty.sol
        composableNFTContract = payable(_composableNFTContract);
        tokenId = _tokenId;
    }

    function _sendValue(address payable receiver, uint256 amount) private {
        (bool success, ) = receiver.call{value: amount}("");
        require(success, "RoyaltyHandler: failed to send value");
        emit RoyaltyPayout(receiver, tokenId, amount);
    }

    receive() external payable {
        uint256 value = msg.value;
        // get child NFTs
        ComposableNFTRoyaltyInterface composableNFT = ComposableNFTRoyaltyInterface(
                composableNFTContract
            );
        ChildNFT[] memory childNFTs = composableNFT.getChildNFTs(tokenId);

        value = value - (value.div(100));

        // split value amoung childNFTs
        for (uint256 i = 0; i < childNFTs.length; i++) {
            ChildNFT memory childNFT = childNFTs[i];

            if (
                !ERC165Checker.supportsInterface(
                    childNFT.contractAddress,
                    type(IERC2981).interfaceId
                )
            ) {
                continue;
            }

            (address payee, ) = IERC2981(childNFT.contractAddress).royaltyInfo(
                childNFT.tokenId,
                value
            );
            _sendValue(payable(payee), value.div(childNFTs.length + 1)); // equal split for now
        }

        // todo: send balance to royalty receiver
        _sendValue(royaltyReceiver, value.div(childNFTs.length + 1));
        // tax value sent by 1%.
        _sendValue(composableNFTContract, msg.value.div(100));
    }

    fallback() external payable {
        revert("RoyaltyHandler: fallback function not yet supported");
    }

    function getBalance() public view returns (uint256) {
        // balance of this contract
        return address(this).balance;
    }
}
