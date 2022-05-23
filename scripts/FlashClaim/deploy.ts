// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

const poolAddress = "0xC87255ade7F6d083d0558efA98d3CA38D9EcF8B5";

async function main() {
  const UserFlashclaimRegistry = await ethers.getContractFactory("UserFlashclaimRegistry");
  const userRegister = await UserFlashclaimRegistry.deploy(poolAddress);
  console.log("UserFlashclaimRegistry deployed to:", userRegister.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
