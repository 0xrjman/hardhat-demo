import { expect } from "chai";
import { ethers } from "hardhat";

describe("Airdrop: Flash Claim Test", function () {
  it("Should pass all check", async function () {
    const [deployer, registerOwner, user1] = await ethers.getSigners();
    const tokenId = 100;

    //create all factory
    const MintableERC20 = await ethers.getContractFactory("MintableERC20");
    const MintableERC721 = await ethers.getContractFactory("MintableERC721");
    const MintableERC1155 = await ethers.getContractFactory("MintableERC1155");
    const MockNToken = await ethers.getContractFactory("MockNToken");
    const UserFlashclaimRegistry = await ethers.getContractFactory("UserFlashclaimRegistry");
    const MockAirdropProject = await ethers.getContractFactory("MockAirdropProject");

    // mint underlying_nft
    const underlying_nft = await MintableERC721.deploy("TestERC721", "TestERC721");
    await underlying_nft.connect(user1).mint(tokenId);
    expect(await underlying_nft.ownerOf(tokenId)).to.equal(user1.address);

    // mint ntoken
    const ntoken = await MockNToken.deploy(underlying_nft.address);
    await underlying_nft.connect(user1).setApprovalForAll(ntoken.address, true);
    await ntoken.connect(user1).mint(user1.address, tokenId);
    expect(await ntoken.ownerOf(tokenId)).to.equal(user1.address);

    //register user, use ntoken as mock pool.
    const user_registry = await UserFlashclaimRegistry.deploy(ntoken.address);
    await user_registry.connect(user1).createReceiver();
    const flashClaimReceiverAddr = await user_registry.userReceivers(user1.address);

    const airdrop_project = await MockAirdropProject.deploy(underlying_nft.address);
    const mockAirdropERC20Address = await airdrop_project.erc20Token();
    const mockAirdropERC20Token = await MintableERC20.attach(mockAirdropERC20Address);
    const mockAirdropERC721Address = await airdrop_project.erc721Token();
    const mockAirdropERC721Token = await MintableERC721.attach(mockAirdropERC721Address);
    const mockAirdropERC1155Address = await airdrop_project.erc1155Token();
    const mockAirdropERC1155Token = await MintableERC1155.attach(mockAirdropERC1155Address);
    const erc1155Id = (await airdrop_project.getERC1155TokenId(tokenId)).toString();

    const applyAirdropEncodedData = MockAirdropProject.interface.encodeFunctionData("claimAirdrop", [tokenId]);
    const receiverEncodedData = ethers.utils.defaultAbiCoder.encode(
        ["uint256[]", "address[]", "uint256[]", "address", "bytes"],
        [
          [1, 2, 3],
          [mockAirdropERC20Address, mockAirdropERC721Address, mockAirdropERC1155Address],
          [0, 0, erc1155Id],
          airdrop_project.address,
          applyAirdropEncodedData,
        ]
    );

    await ntoken.connect(user1).flashClaim(flashClaimReceiverAddr, [100], receiverEncodedData);

    expect(await mockAirdropERC20Token.balanceOf(user1.address)).to.be.equal(await airdrop_project.erc20Bonus());
    expect(await mockAirdropERC721Token.balanceOf(user1.address)).to.be.equal(
        await airdrop_project.erc721Bonus()
    );
    expect(await mockAirdropERC1155Token.balanceOf(user1.address, erc1155Id)).to.be.equal(
        await airdrop_project.erc1155Bonus()
    );
  });
});
