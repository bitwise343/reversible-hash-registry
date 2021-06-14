// SPDX-License-Identifier: MIT
const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const utils = require("../scripts/utils.js");


describe("EIP173: Ownable", () => {
    let eip173, account1, account2;

    before(async () => {
        eip173 = await utils.deployContract("EIP173");
        [account1, account2] = await ethers.getSigners();
    });

    it("should set account1 to owner", async () => {
        expect(await eip173.owner()).to.equal(account1.address);
    });

    it("should emit OwnershipTransferred(account1, account2)", async () => {
        expect(eip173.transferOwnership(account2.address))
          .to.emit(eip173, 'OwnershipTransferred')
          .withArgs(account1.address, account2.address);
    });

    it("should set account2 to owner", async () => {
        expect(await eip173.owner()).to.equal(account2.address);
    });

    it("should revert with Failed: not owner", async () => {
        await expect(eip173.transferOwnership(account2.address))
            .to.be.revertedWith('Failed: not owner');
    });

    it("should revert with Failed: already owner", async () => {
        await expect(eip173.connect(account2).transferOwnership(account2.address))
            .to.be.revertedWith('Failed: already owner');
    });

});
