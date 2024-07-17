// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import {IYieldBearingToken}  from "..//interfaces/IYieldBearingToken.sol";
import {AggregatorV3Interface} from "chainlink/src/v0.5/interfaces/AggregatorV3Interface.sol";


/// @title CLAggregatorV3Adapter
/// @author Khaled G. @ Allez Labs
/// @custom:contact kh.grira@gmail.com
/// @notice This is an adapter for Chainlink Aggregator V3 to make it an IYieldBearingToken and implement convertToAssets
contract CLAggregatorV3Adapter is IYieldBearingToken {

    AggregatorV3Interface public immutable CL_AGGREGATOR; 

    constructor(
        address _clAggregator
    ) {
        CL_AGGREGATOR = AggregatorV3Interface(_clAggregator);
    }

    function convertToAssets(uint256) external view returns (uint256 conversionRate) {
        (, int256 answer,,,) = CL_AGGREGATOR.latestRoundData();
        conversionRate = uint256(answer);
    }
    
}