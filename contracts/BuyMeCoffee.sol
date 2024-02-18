// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

library SepoliaAddresses {
    address constant eth = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
}

contract BuyMeCoffee {
    // Connections
    using PriceUtils for uint256;

    // Constants
    uint constant minDonation = 10 * 1e18; // 10 USD

    // State Variables
    address[] public fans;
    mapping(address => uint) public donations;
    event DonationFailed(uint256 errorCode, string reason);
    event Log(string message, address sender, uint256 value, bytes data);

    constructor() {}

    fallback() external payable {
        emit Log("FALLBACK", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Log("RECEIVE", msg.sender, msg.value, "");
    }

    function donate() external payable returns (string memory) {
        emit Log("DONATE-FUNC", msg.sender, msg.value, "");
        uint256 donationInUsd = msg.value.toUsd();

        if (donationInUsd < minDonation) {
            emit DonationFailed(1, "Minimum donation is 10 USD");
            return "Minimum donation is 10 USD";
        }

        require(donationInUsd >= minDonation, "Minimum donation is 10 USD");

        fans.push(msg.sender); // adding people who donated to the fans array
        donations[msg.sender] += donationInUsd; // adding the donation to the donations mapping

        return
            string.concat(
                "Thank you for your donation of USD ",
                Strings.toString(donationInUsd)
            );
    }

    function getCurrentBalance() public view returns (uint256) {
        return address(this).balance.toUsd();
    }
}

contract TestFunderContract {
    // Connections
    using PriceUtils for uint256;

    constructor() payable {
        uint256 initValueInUsd = msg.value.toUsd();
        require(initValueInUsd >= 1000 * 1e18, "Minimum donation is 1000 USD");
    }

    function currentBalance() public view returns (uint256) {
        return address(this).balance.toUsd();
    }

    function donate(
        address payable contractAddress,
        uint256 amountInUsd
    ) public returns (string memory) {
        uint256 ethPriceWei = ChainlinkDataFeed.priceOf(SepoliaAddresses.eth);
        uint256 ethPrice = ethPriceWei / 1e18;
        uint256 amountInWei = (amountInUsd * 1e18) / ethPrice;
        console.log("Donating Wei %d", amountInWei);

        (bool success, bytes memory data) = contractAddress.call{
            value: amountInWei
        }(abi.encodeWithSignature("donate()"));

        string memory revertReason;

        if (!success) {
            if (data.length > 0) {
                // Attempt to extract a revert reason string
                // Solidity 0.6.0+ revert reason format is 0x08c379a0 (4 bytes) + 32 bytes offset + 32 bytes length
                require(data.length >= 68, "Invalid revert reason");
                assembly {
                    revertReason := add(data, 68)
                }
            } else {
                revert("External call failed without revert reason");
            }
        } else {
            // External call succeeded
        }

        return success ? "Thank you for your donation!" : revertReason;
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

        return (price * ethPrice);
    }
}
