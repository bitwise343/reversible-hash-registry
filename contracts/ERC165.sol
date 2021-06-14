// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./EIP173.sol";

// https://eips.ethereum.org/EIPS/eip-173
// https://eips.ethereum.org/EIPS/eip-165
contract ERC165 is EIP173 {

    mapping (bytes4 => bool) internal supportedInterfaces;

    constructor() EIP173() {
        supportedInterfaces[0x7f5828d0] = true; // ERC173: ownable
        supportedInterfaces[0x01ffc9a7] = true; // ERC165: this
    }

    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return supportedInterfaces[interfaceId];
    }

    function addInterface(bytes4 interfaceId) public {
        require(msg.sender == _owner, "Failed: not owner");
        require(interfaceId != bytes4(0xffffffff), "Failed: 0xffffffff");
        require(interfaceId != bytes4(0x00000000), "Failed: 0x00000000");

        supportedInterfaces[interfaceId] = true;
    }
}
