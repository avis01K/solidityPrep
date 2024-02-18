// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "hardhat/console.sol";

contract HelloDecentralisation {
    uint public secretNumber;

    constructor() {
        console.log("Secret Number set as 666!");
        secretNumber = 666;
    }

    function updateSecret(uint secretNumber_) public {
        secretNumber = secretNumber_;
        console.log("Secret Number set as %d!", secretNumber);
    }

    function getSecret() public view returns (uint) {
        return secretNumber;
    }
}

// Pure and View Functions

// Storage, calldata and memory

// payable functions

// Global Variables - msg.sender, msg.value,...and more

// 1ETH = 1,000,000,000 Gwei = 1,000,000,000,000,000,000 Wei

// 1ETH = 1e18 Wei
// 1ETH = 1e9 Gwei

// require, assert, revert
