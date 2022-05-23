// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import "./AirdropFlashClaimReceiver.sol";

contract UserFlashclaimRegistry {
    address public pool;
    mapping(address => address) public userReceivers;

    constructor(address pool_) {
        pool = pool_;
    }

    function createReceiver() public {
        address caller = msg.sender;
        AirdropFlashClaimReceiver receiver = new AirdropFlashClaimReceiver(caller, pool);
        userReceivers[caller] = address(receiver);
    }
}
