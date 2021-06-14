// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC721Metadata.sol";


contract EIP712 is ERC721Metadata {

    mapping (bytes32 => address) internal _typehashImplementation;

    constructor(
        string memory name, string memory symbol, string memory uri
    ) ERC721Metadata(name, symbol, uri) {}

    function addTypehash(bytes32 typehash, address implementation) public {
        require(msg.sender == _owner, "Failed: not owner");

        _typehashImplementation[typehash] = implementation;
    }

    function removeTypehash(bytes32 typehash) public {
        require(msg.sender == _owner, "Failed: not owner");
        require(_typehashImplementation[typehash] != address(0), "Failed: no implementation");
        _typehashImplementation[typehash] = address(0);
    }

    function hashByTypehash(bytes32 typehash, bytes memory encodedArgs) public view returns (bytes32) {
        address typehashImplementation = _typehashImplementation[typehash];
        require(typehashImplementation != address(0), "Failed: no implementation");

        (bool success, bytes memory returndata) = typehashImplementation.staticcall(abi.encodePacked(encodedArgs));
        if (!success) { revert("Failed: staticcall"); } else {
            bytes32 typehash;
            assembly {
                typehash := mload(add(returndata, 32))
            }
            return typehash;
        }
    }

    function typehashImplementation(bytes32 typehash) public view returns (address) {
        return _typehashImplementation[typehash];
    }
}
