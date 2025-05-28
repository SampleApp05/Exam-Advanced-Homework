// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract MockAggregatorV3Interface is AggregatorV3Interface {
    int256 public latestPrice;
    uint8 public decimals;
    uint256 public version = 1;
    string public description = "Mock Aggregator V3 Interface";

    constructor(int256 initialPrice, uint8 _decimals) {
        latestPrice = initialPrice;
        decimals = _decimals;
    }

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (_roundId, latestPrice, 0, 0, 0);
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80, int256 price, uint256, uint256, uint80)
    {
        return (0, latestPrice, 0, 0, 0);
    }

    function setLatestPrice(int256 newPrice) external {
        latestPrice = newPrice;
    }
}
