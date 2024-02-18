// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract HelloDecentralisation {
    uint public secretNumber;

    constructor() {
        console.log("Secret Number set as 666!");
        secretNumber = 666;
    }

    function updateSecret(uint secretNumber_) public returns (string memory) {
        secretNumber = secretNumber_;
        console.log("Secret Number set as %d!", secretNumber);

        return
            string.concat(
                "Hello Decentralisation, Secret Number set as ",
                Strings.toString(secretNumber)
            );
    }

    function getSecret() public view returns (uint) {
        return secretNumber;
    }
}

// Pure and View Functions

// Storage [Permananty update state] ,
// memory [Local memory, not stored in blockchain] and
// calldata [Local memory, not stored in blockchain. Used for function arguments and return values. Helps save gas.]

// payable functions

// Global Variables - msg.sender, msg.value,...and more

// 1ETH = 1,000,000,000 Gwei = 1,000,000,000,000,000,000 Wei

// 1ETH = 1e18 Wei
// 1ETH = 1e9 Gwei

// require, assert, revert
