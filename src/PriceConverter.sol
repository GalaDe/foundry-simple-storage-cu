// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/*
    In this case library is more appropriate, because it:
    
        - Stateless (cannot store state variables)
        - Used for reusable functions
        - Allows code reuse without inheritance
        - Optimized at compile-time (reduces gas in many cases)

*/
library PriceConverter {
    //internal view functions allow the library to be linked at compile-time into other contracts — no deployment needed.
    function getPrice() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306 // contract address of the Chainlink ETH/USD price feed on the Sepolia testnet.
        );

        //Ignoring 4 of the 5 return values using commas and _-like syntax
        //Storing only the answer (which is the ETH/USD price) in the answer variable
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        // ETH/USD rate in 18 digit
        return uint256(answer * 10000000000);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // ETH/USD price is 8 decimals, need to scale to 18 decimals
        return (uint256(price) * ethAmount) / 1e8;
    }
}
