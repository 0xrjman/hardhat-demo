import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { MyToken } from "../typechain";

describe("MyToken", function () {
    let Token, token: MyToken, owner: Signer, addr1: Signer, addr2: Signer
    let ownerAddress: string, addr1Address: string, addr2Address: string
    beforeEach(async () => {
        Token = await ethers.getContractFactory('MyToken');
        token = await Token.deploy();
        [owner, addr1, addr2] = await ethers.getSigners()
        ownerAddress = await owner.getAddress()
        addr1Address = await addr1.getAddress()
        addr2Address = await addr2.getAddress()
    })

    describe('test deploy', () => {
        it("owner is correct", async () => {
            expect(await token.owner()).to.equal(ownerAddress)
        })

        it("symbol is correct", async () => {
            expect(await token.symbol()).to.equal("MYT")
        })

        it("owner has total supply", async () => {
            expect(await token.totalSupply()).to.equal(await token.balanceOf(ownerAddress))
        })
    })

    describe('test transfer', () => {
        it("transfer should send correct amount", async () => {
            const amount = 10
            await token.transfer(addr1Address, amount)

            // const transfer = await token.transfer(addr1Address, amount)
            // wait until the transaction is mined
            // const receipt = await transfer.wait();
            // console.log(receipt)

            expect(await token.balanceOf(addr1Address)).to.equal(amount)
            const totalSupply = await token.totalSupply()
            expect(await token.balanceOf(ownerAddress)).to.equal(totalSupply.sub(amount))
        
            await token.connect(addr1).transfer(addr2Address, amount)
            expect(await token.balanceOf(addr2Address)).to.equal(amount)
        })
    })    
});
