// SPDX-License-Identifier: MIT
const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const utils = require("../scripts/utils.js");


describe("ERC165: Interfaces", () => {
    let erc165;

    before(async () => {
        erc165 = await utils.deployContract("ERC165");
    });

    it("should support ERC165 interface", async () => {
        expect(await erc165.supportsInterface("0x01ffc9a7")).to.be.true;
    });

    it("should support EIP173 interface", async () => {
        expect(await erc165.supportsInterface("0x7f5828d0")).to.be.true;
    });
});
