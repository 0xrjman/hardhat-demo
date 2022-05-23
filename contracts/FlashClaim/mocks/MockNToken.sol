// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import {IERC20} from "../dependencies/openzeppelin/contracts/IERC20.sol";
import {IERC721} from "../dependencies/openzeppelin/contracts/IERC721.sol";
import {ERC721} from "../dependencies/openzeppelin/contracts/ERC721.sol";
import {IFlashClaimReceiver} from "../interfaces/IFlashClaimReceiver.sol";
import {ReentrancyGuard} from "../dependencies/openzeppelin/contracts/ReentrancyGuard.sol";
import {IERC721Receiver} from "../dependencies/openzeppelin/contracts/IERC721Receiver.sol";

contract MockNToken is ERC721, ReentrancyGuard, IERC721Receiver {
    address public underlyingAsset;

    event FlashClaim(address indexed target, address indexed initiator, address indexed nftAsset, uint256 tokenId);

    constructor(address underlyingAsset_) ERC721("Mock_NToken", "Mock_NToken"){
        underlyingAsset = underlyingAsset_;
    }

    function mint(address to, uint256 tokenId) external {
        IERC721(underlyingAsset).transferFrom(msg.sender, address(this), tokenId);
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(owner == msg.sender, "not the owner of MockNToken");
        _burn(tokenId);

        IERC721(underlyingAsset).safeTransferFrom(address(this), owner, tokenId);
    }

    function flashClaim(
        address receiverAddress,
        uint256[] calldata nftTokenIds,
        bytes calldata params
    ) external nonReentrant {
        uint256 i;
        IFlashClaimReceiver receiver = IFlashClaimReceiver(receiverAddress);

        // !!!CAUTION: receiver contract may reentry mint, burn, flashloan again

        require(receiverAddress != address(0), "NToken: zero address");
        require(nftTokenIds.length > 0, "NToken: empty token list");

        // only token owner can do flashloan
        for (i = 0; i < nftTokenIds.length; i++) {
            require(ownerOf(nftTokenIds[i]) == _msgSender(), "NToken: caller is not owner");
        }

        // step 1: moving underlying asset forward to receiver contract
        for (i = 0; i < nftTokenIds.length; i++) {
            IERC721(underlyingAsset).safeTransferFrom(address(this), receiverAddress, nftTokenIds[i]);
        }

        // setup 2: execute receiver contract, doing something like aidrop
        require(
            receiver.executeOperation(underlyingAsset, nftTokenIds, params),
            "NToken: invalid flashloan executor return"
        );

        // setup 3: moving underlying asset backword from receiver contract
        for (i = 0; i < nftTokenIds.length; i++) {
            IERC721(underlyingAsset).safeTransferFrom(receiverAddress, address(this), nftTokenIds[i]);

            emit FlashClaim(receiverAddress, _msgSender(), underlyingAsset, nftTokenIds[i]);
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
