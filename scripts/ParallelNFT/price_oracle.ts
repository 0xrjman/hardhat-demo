// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import { ContractTransaction } from "ethers";

async function main() {
  console.log("Deploying NFTFloorOracle...");
  const NftOraclePrice = await ethers.getContractFactory("NFTFloorOracle");
  const nftOraclePrice = await NftOraclePrice.deploy();
  console.log("NFTFloorOracle deployed to:", nftOraclePrice.address);
}

export const waitForTx = async (tx: ContractTransaction) => await tx.wait(1);

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});