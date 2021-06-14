// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC165.sol";
import "./ERC721TokenReceiver.sol";

// https://eips.ethereum.org/EIPS/eip-165
// https://eips.ethereum.org/EIPS/eip-721
contract ERC721 is ERC165 {

    mapping (uint256 => address) internal _ownerOf;
    mapping (address => uint256) internal _balanceOf;
    mapping (uint256 => address) internal _approved;
    mapping (address => mapping (address => bool)) internal _approvedForAll;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor() ERC165() {
        supportedInterfaces[0x80ac58cd] = true; // ERC721: this
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return _ownerOf[tokenId];
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balanceOf[owner];
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        return _approved[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _approvedForAll[owner][operator];
    }

    function approve(address approved, uint256 tokenId) public {
        address sender = msg.sender;
        address tokenOwner = _ownerOf[tokenId];

        require(
            sender == tokenOwner || _approvedForAll[tokenOwner][sender],
            "Failed: not owner or operator"
        );

        _approved[tokenId] = approved;
    }

    function setApprovalForAll(address operator, bool approval) public {
        address tokenOwner = msg.sender;
        bool status = _approvedForAll[tokenOwner][operator];

        require(status != approval, "Failed: already set");

        _approvedForAll[tokenOwner][operator] = approval;
        emit ApprovalForAll(tokenOwner, operator, approval);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        address sender = msg.sender;
        address tokenOwner = _ownerOf[tokenId];

        require(
            sender == tokenOwner
            || _approvedForAll[tokenOwner][sender]
            || sender == _approved[tokenId],
            "Failed: not owner, operator, or approved"
        );
        require(to != address(0), "Failed: address(0)");
        require(to != tokenOwner, "Failed: already owner");

        _approved[tokenId] = address(0);
        _ownerOf[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        address sender = msg.sender;
        address tokenOwner = _ownerOf[tokenId];

        require(
            sender == tokenOwner
            || _approvedForAll[tokenOwner][sender]
            || sender == _approved[tokenId],
            "Failed: not owner, operator, or approved"
        );
        require(to != address(0), "Failed: address(0)");
        require(to != tokenOwner, "Failed: already owner");


        uint256 codeSize;
        assembly {
            codeSize := extcodesize(to)
        }
        if (codeSize > 0) {
            (bool success, bytes memory response) = to.call(
                abi.encodePacked(
                    ERC721TokenReceiver.onERC721Received.selector,
                    abi.encode(
                        sender, to, tokenId, data
                    )
                )
            );
            if (!success) { revert("Failed: call to ERC721TokenReceiver"); } else {
                bytes4 _response;
                assembly {
                    _response := mload(add(response, 32))
                }
                require(
                    _response == ERC721TokenReceiver.onERC721Received.selector,
                    "Failed: onERC721Received"
                );
            }
        }

        _approved[tokenId] = address(0);
        _ownerOf[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from, address to, uint256 tokenId
    ) public {
        address sender = msg.sender;
        address tokenOwner = _ownerOf[tokenId];

        require(
            sender == tokenOwner
            || _approvedForAll[tokenOwner][sender]
            || sender == _approved[tokenId],
            "Failed: not owner, operator, or approved"
        );
        require(to != address(0), "Failed: address(0)");
        require(to != tokenOwner, "Failed: already owner");


        uint256 codeSize;
        assembly {
            codeSize := extcodesize(to)
        }
        if (codeSize > 0) {
            (bool success, bytes memory response) = to.call(
                abi.encodePacked(
                    ERC721TokenReceiver.onERC721Received.selector,
                    abi.encode(
                        sender, to, tokenId, new bytes(0)
                    )
                )
            );
            if (!success) { revert("Failed: call to ERC721TokenReceiver"); } else {
                bytes4 _response;
                assembly {
                    _response := mload(add(response, 32))
                }
                require(
                    _response == ERC721TokenReceiver.onERC721Received.selector,
                    "Failed: onERC721Received"
                );
            }
        }

        _approved[tokenId] = address(0);
        _ownerOf[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function mint(uint256 tokenId, address to) public {
        address tokenOwner = _ownerOf[tokenId];

        require(msg.sender == _owner, "Failed: not owner");
        require(tokenOwner == address(0), "Failed: already exists");

        _ownerOf[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function burn(uint256 tokenId, address to) public {
        address tokenOwner = _ownerOf[tokenId];

        require(msg.sender == _owner, "Failed: not owner");
        require(tokenOwner != address(0), "Failed: does not exist");

        _ownerOf[tokenId] = address(0);
        _approved[tokenId] = address(0);
        emit Transfer(tokenOwner, address(0), tokenId);
    }
}
