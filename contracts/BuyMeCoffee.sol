// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "hardhat/console.sol";

library SepoliaAddresses {
    address constant eth = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
}

contract BuyMeCoffee {
    // Connections
    using PriceUtils for uint256;

    // Constants
    uint constant minDonation = 10; // 10 USD

    address[] public fans;
    mapping(address => uint) public donations;

    constructor() {}

    function donate() public payable {
        uint256 donationInUsd = msg.value.toUsd();

        require(donationInUsd >= minDonation, "Minimum donation is 10 USD");

        fans.push(msg.sender); // adding people who donated to the fans array
        donations[msg.sender] += donationInUsd; // adding the donation to the donations mapping

        console.log("Thank you for your donation of %d USD!", donationInUsd);
    }
}

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library ChainlinkDataFeed {
    function priceOf(address token) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(token);
        (, int price, , , ) = priceFeed.latestRoundData();

        return uint256(price * 1e10); // price from chainlink feed is 8 decimals, we need 18, so we multiply by 1e10. This way we return the price in wei.
    }
}

library PriceUtils {
    function toUsd(uint256 price) public view returns (uint256) {
        uint256 ethPrice = ChainlinkDataFeed.priceOf(SepoliaAddresses.eth);

        return (price * ethPrice) / 1e18;
    }
}
