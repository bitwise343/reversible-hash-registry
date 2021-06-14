// SPDX-License-Identifier: MIT
const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const utils = require("../scripts/utils.js");


describe("ERC721: Non-Fungible Tokens", () => {
    let erc721, account1, account2;
    let validReceiver, invalidReceiverSuccessfulCall, invalidReceiverFailCall;

    before(async () => {
        [account1, account2] = await ethers.getSigners();

        validReceiver = await utils.deployContract("ValidReceiver");
        invalidReceiverSuccessfulCall = await utils.deployContract(
            "InvalidReceiverSuccessfulCall"
        );
        invalidReceiverFailCall = await utils.deployContract(
            "InvalidReceiverFailCall"
        );
        erc721 = await utils.deployContract(
            "ERC721Metadata", ["ERC721 NFTs", "E721", "https://example.com/"]
        );
    });

    describe("interfaces", () => {
        it("should support ERC165", async () => {
            expect(await erc721.supportsInterface("0x01ffc9a7")).to.be.true;
        });

        it("should support EIP173", async () => {
            expect(await erc721.supportsInterface("0x7f5828d0")).to.be.true;
        });

        it("should support ERC721", async () => {
            expect(await erc721.supportsInterface("0x80ac58cd")).to.be.true;
        });
    });

    describe("minting", () => {
        it("should emit Transfer(address(0), account1, 1123581321345589)", async () => {
            expect(
                await erc721.mint(1123581321345589, account1.address)
            ).to.emit(erc721, "Transfer").withArgs(
                "0x0000000000000000000000000000000000000000", account1.address, 1123581321345589
            );
        });

        it("should mint token 1123581321345589 to account1", async () => {
            expect(await erc721.ownerOf(1123581321345589)).to.equal(account1.address);
        });

    });

    describe("transferring", async () => {
        it("should emit Transfer(account1, account2, 1123581321345589)", async () => {
            expect(
                await erc721["safeTransferFrom(address,address,uint256)"](
                    account1.address, account2.address, 1123581321345589
                )
            ).to.emit(erc721, "Transfer").withArgs(
                account1.address, account2.address, 1123581321345589
            );
        });

        it("should transfer token 1123581321345589 to account2", async () => {
            expect(await erc721.ownerOf(1123581321345589)).to.equal(account2.address);
        });

        it("should emit Transfer(account2, validReceiver.address, 1123581321345589)", async () => {
            expect(
                await erc721.connect(account2)["safeTransferFrom(address,address,uint256)"](
                    account2.address, validReceiver.address, 1123581321345589
                )
            ).to.emit(erc721, "Transfer").withArgs(
                account2.address, validReceiver.address, 1123581321345589
            );
        });

        it("should transfer token 1123581321345589 to validReceiver", async () => {
            expect(await erc721.ownerOf(1123581321345589)).to.equal(validReceiver.address);
        });

        it("should emit Transfer(validReceiver.address, account1, 1123581321345589)", async () => {
            expect(
                await validReceiver.transfer(
                    erc721.address, account1.address, 1123581321345589
                )
            ).to.emit(erc721, "Transfer").withArgs(
                validReceiver.address, account1.address, 1123581321345589
            );
        });

        it("should transfer token 1123581321345589 to account1", async () => {
            expect(await erc721.ownerOf(1123581321345589)).to.equal(account1.address);
        });
    });

    describe("reverts", () => {
        it("should revert with 'Failed: onERC721Received'", async () => {
            await expect(
                erc721["safeTransferFrom(address,address,uint256)"](
                    account1.address, invalidReceiverSuccessfulCall.address, 1123581321345589
                )
            ).to.be.revertedWith("Failed: onERC721Received");
        });

        it("should revert with 'Failed: call to ERC721TokenReceiver'", async () => {
            await expect(
                erc721["safeTransferFrom(address,address,uint256)"](
                    account1.address, invalidReceiverFailCall.address, 1123581321345589
                )
            ).to.be.revertedWith("Failed: call to ERC721TokenReceiver");
        });

        it("should revert with 'Failed: not owner, operator, or approved'", async () => {
            await expect(
                erc721.connect(account2)["safeTransferFrom(address,address,uint256)"](
                    account2.address, account1.address, 1123581321345589
                )
            ).to.be.revertedWith("Failed: not owner, operator, or approved");
        });
    });

    describe("state variables", () => {
        it("should return name 'ERC721 NFT'", async () => {
            expect(await erc721.name()).to.equal("ERC721 NFTs");
        });

        it("should return symbol 'E721'", async () => {
            expect(await erc721.symbol()).to.equal("E721");
        });

        it("should return baseURI 'https://example.com/'", async () => {
            expect(await erc721.baseURI()).to.equal("https://example.com/");
        });

        it("should set tokenURI(1123581321345589) to 'https://example.com/fake'", async () => {
            await erc721.setTokenURI(1123581321345589, "fake");
            expect(await erc721.tokenURI(1123581321345589)).to.equal("https://example.com/fake");
        });
    });
});
