// SPDX-License-Identifier: MIT
const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const utils = require("../scripts/utils.js");


describe("EIP712: Typehash", () => {
    let account1,
        eip712,
        tokenId,
        typehash,
        typehashImpl,
        implAddr,
        abiCoder;

    before(async () => {
        [account1] = await ethers.getSigners();
        eip712 = await utils.deployContract(
            "EIP712", ["EIP712 Implementation", "E712", "https://fake.uri/"]
        );
        typehashImpl = await utils.deployContract(
            "NiftyVaultTypehashImplementation"
        );
        abiCoder = ethers.utils.defaultAbiCoder;
    });

    describe("adding typehash", () => {
        it("should add NiftyVaultTypehashImplementation", async () => {
            typehash = await typehashImpl.NIFTYVAULT_TYPEHASH();
            implAddr = typehashImpl.address;
            await eip712.addTypehash(
                typehash,
                implAddr
            );
            expect(
                await eip712.typehashImplementation(typehash)
            ).to.equal(implAddr);
        });
    });

    describe("minting typehash", () => {
        it("should emit Transfer(address(0), account1, tokenId)", async () => {
            tokenId = new ethers.BigNumber.from(typehash);
            expect(
                await eip712.mint(tokenId, account1.address)
            ).to.emit(eip712, "Transfer").withArgs(
                "0x0000000000000000000000000000000000000000",
                account1.address,
                tokenId
            );
        });

        it("should mint token tokenId to account1", async () => {
            expect(await eip712.ownerOf(tokenId)).to.equal(account1.address);
        });
    });

    describe("encoding and hashing", () => {
        it("should properly hash an NFT", async () => {
            let nftEncodedArgs = await typehashImpl.encodeNFT(
                eip712.address,
                tokenId
            );
            let nftHash = await typehashImpl.hashNFT(nftEncodedArgs);

            let nftHashSelector = typehashImpl.interface.getSighash(
                'hashNFT((address,uint256))'
            );
            let encodedArgs = utils.encodeTypehash(nftHashSelector,
                ["address", "uint256"],
                [eip712.address, tokenId]
            );
            let nftHashEip712 = await eip712.hashByTypehash(
                typehash, encodedArgs
            );

            expect(nftHashEip712).to.equal(nftHash);
        });
    });
});
