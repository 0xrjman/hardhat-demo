// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721Example is Ownable, ERC721("HelloNft", "HNFT"){
    uint tokenId;
    mapping(address=>tokenMetaData[]) public ownershipRecord;
    
    struct tokenMetaData{
        uint tokenId;
        uint timeStamp;
        string tokenURI;
    }
    
    function mintToken(address recipient) onlyOwner public {
        require(owner()!=recipient, "Recipient cannot be the owner of the contract");
        _safeMint(msg.sender, tokenId);
        ownershipRecord[recipient].push(tokenMetaData(tokenId, block.timestamp, "https://miro.medium.com/max/1120/1*k_EY7dcLYB5Z5k8zhMcv6g.png"));
        tokenId = tokenId + 1;
    }
    
    
}