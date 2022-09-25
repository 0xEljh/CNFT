// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ComposableNFT.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "./RoyaltyHandler.sol";

abstract contract ComposableNFTRoyalty is ComposableNFT, ERC721Royalty {
    mapping(uint256 => address) private _royaltyHandlers;
    mapping(uint256 => uint96[]) private _valueFractions;

    constructor() {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId)
        internal
        virtual
        override(ComposableNFT, ERC721Royalty)
    {
        ComposableNFT._burn(tokenId);
        _resetTokenRoyalty(tokenId);
        delete _valueFractions[tokenId];
    }

    function _createRoyaltyHandler(
        address payable _royaltyReceiver,
        uint256 _tokenId
    ) internal {
        // todo: create if contract does not exist. otherwise, use existing contract.
        RoyaltyHandler royaltyHandler = new RoyaltyHandler(
            _royaltyReceiver,
            address(this),
            _tokenId
        );
        _royaltyHandlers[_tokenId] = address(royaltyHandler);
    }

    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual override {
        _createRoyaltyHandler(payable(receiver), tokenId);
        super._setTokenRoyalty(
            tokenId,
            _royaltyHandlers[tokenId],
            feeNumerator
        );
    }

    function _valueDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    function _sumArray(uint96[] memory array) internal pure returns (uint96) {
        uint96 sum = 0;
        for (uint256 i = 0; i < array.length; i++) {
            sum += array[i];
        }
        return sum;
    }

    function _setValueFraction(uint256 tokenId, uint96[] memory valueFractions)
        internal
        virtual
    {
        require(
            valueFractions.length == _childNFTs[tokenId].length,
            "ComposableNFTRoyalty: valueFractions length must match childNFTs length"
        );
        require(
            _sumArray(valueFractions) <= _valueDenominator(),
            "ComposableNFTRoyalty: sum of valueFractions cannot exceed 10000"
        );
        _valueFractions[tokenId] = valueFractions;
    }

    // @dev this contract must be payable to receive and hold balance.
    receive() external payable {}

    fallback() external payable {}

    function getBalance() public view returns (uint256) {
        // balance of this contract. Tax collected.
        return address(this).balance;
    }

    // todo: Handle case where childNFTs are added after valueFractions are set.
    // todo: Handle case where childNFTs are removed after valueFractions are set.
}
