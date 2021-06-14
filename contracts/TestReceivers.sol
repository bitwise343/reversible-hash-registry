// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "./ERC721TokenReceiver.sol";

interface ERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract ValidReceiver {
    function onERC721Received(
        address _operator, address _from, uint256 _tokenId, bytes memory _data
    ) public returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }

    function transfer(address token, address to, uint256 tokenId) public {
        ERC721(token).safeTransferFrom(address(this), to, tokenId);
    }
}

contract InvalidReceiverSuccessfulCall {
    function onERC721Received(
        address _operator, address _from, uint256 _tokenId, bytes memory _data
    ) public returns (bytes4) {
        return bytes4(0x00000000);
    }
}

contract InvalidReceiverFailCall {
    uint private x;
    function thisContractDoesNotHaveTheERC721TokenReceiverABI() public {}
}
