// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC721.sol";


contract ERC721Metadata is ERC721 {

    string private _name;
    string private _symbol;
    string private _baseURI;
    mapping (uint256 => string) private _tokenURIs;

    constructor(
        string memory initName, string memory initSymbol, string memory initBaseURI
    ) ERC721() {
        _name = initName;
        _symbol = initSymbol;
        _baseURI = initBaseURI;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return string(abi.encodePacked(_baseURI, _tokenURIs[tokenId]));
    }

    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

    function setTokenURI(uint256 tokenId, string memory newTokenURI) public {
        require(msg.sender == _owner, "Failed: not owner");

        string memory currentURI = _tokenURIs[tokenId];
        uint256 stringSize;
        assembly {
            stringSize := mload(currentURI)
        }
        require(stringSize == 0, "Failed: tokenURI already set");

        _tokenURIs[tokenId] = newTokenURI;
    }

}
