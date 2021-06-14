// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


contract NiftyVaultTypehashImplementation {

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    struct NiftyVault {
        address vaultAddress;
        NFT nft;
    }

    struct NFT {
        address tokenContract;
        uint256 tokenId;
    }

    bytes32 public immutable EIP712DOMAIN_TYPEHASH = keccak256(abi.encodePacked(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    ));

    bytes32 public immutable DOMAIN_SEPARATOR = keccak256(abi.encode(
        keccak256(abi.encodePacked(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        )),
        keccak256(abi.encodePacked("NiftyVaultTypehashImplementation")),
        keccak256(abi.encodePacked("0.1.0")),
        uint256(1),
        address(this)
    ));

    bytes32 public immutable NIFTYVAULT_TYPEHASH = keccak256(abi.encodePacked(
        "NiftyVault(address vaultAddress,NFT nft)NFT(address tokenContract,uint256 tokenId)"
    ));

    bytes32 public immutable NFT_TYPEHASH = keccak256(
        abi.encodePacked("NFT(address tokenContract,uint256 tokenId)")
    );

    function encodeNFT(
        address tokenContract, uint256 tokenId
    ) public pure returns (NFT memory nft) {
        nft = NFT({tokenContract: tokenContract, tokenId: tokenId});
    }

    function hashNFT(
        NFT memory nft
    ) public view returns (bytes32 nftHash) {
        nftHash = keccak256(abi.encode(
            NFT_TYPEHASH,
            nft.tokenContract,
            nft.tokenId
        ));
    }

    function digestNFT(
        NFT memory nft
    ) public view returns (bytes32 nftDigest) {
        nftDigest = keccak256(abi.encode(
            "\\x19\\x01",
            DOMAIN_SEPARATOR,
            hashNFT(nft)
        ));
    }

    function encodeNiftyVault(
        address vaultAddress, address tokenContract, uint256 tokenId
    ) public pure returns (NiftyVault memory niftyVault) {
        NFT memory nft = NFT({tokenContract: tokenContract, tokenId: tokenId});
        niftyVault = NiftyVault({
            vaultAddress: vaultAddress,
            nft: nft
        });
    }

    function hashNiftyVault(
        NiftyVault memory niftyVault
    ) public view returns (bytes32 niftyVaultHash) {
        niftyVaultHash = keccak256(abi.encode(
            NIFTYVAULT_TYPEHASH,
            niftyVault.vaultAddress,
            hashNFT(niftyVault.nft)
        ));
    }

    function digestNiftyVault(
        NiftyVault memory niftyVault
    ) public view returns (bytes32 niftyVaultDigest) {
        niftyVaultDigest = keccak256(abi.encode(
            "\\x19\\x01",
            DOMAIN_SEPARATOR,
            hashNiftyVault(niftyVault)
        ));
    }
}
