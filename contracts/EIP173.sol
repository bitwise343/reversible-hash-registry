// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// https://eips.ethereum.org/EIPS/eip-173
contract EIP173 {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public {
        address currentOwner = _owner;
        require(msg.sender == currentOwner, "Failed: not owner");
        require(newOwner != currentOwner, "Failed: already owner");

        _owner = newOwner;
        emit OwnershipTransferred(currentOwner, newOwner);
    }
}
