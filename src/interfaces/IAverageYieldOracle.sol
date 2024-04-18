// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {AutomationCompatibleInterface} from "chainlink/src/v0.8/automation/AutomationCompatible.sol";
import {IYieldBearingToken} from "./IYieldBearingToken.sol";

/// @title IAverageYieldOracle
/// @author Khaled G. @ Allez Labs
/// @custom:contact kh.grira@gmail.com
/// @notice Interface for the average yield oracle
interface IAverageYieldOracle is AutomationCompatibleInterface {
    /// @notice Emitted when the average yield is updated
    /// @param averageYield The new average yield
    /// @param conversionRate The new conversion rate of the yield bearing token
    /// @param timestamp The timestamp of the update
    event AverageYieldUpdated(int averageYield, uint conversionRate, uint timestamp);

    /// @notice Returns the yield bearing token or a wrapper contract that returns the exchange rates
    function YIELD_BEARING_TOKEN() external view returns (IYieldBearingToken);

    /// @notice Returns the interval of updates
    function INTERVAL() external view returns (uint);

    /// @notice Returns the number of conversion rates to store, 8 windows -> 7 APRs generated
    function WINDOW() external view returns (uint);

    /// @notice Returns the conversion sample for the yield bearing token 
    function CONVERSION_SAMPLE() external view returns (uint);

    /// @notice Returns the scaling factor to bring the yield to a given unit (WAD, RAY, etc.)
    function SCALE_FACTOR() external view returns (int);

    /// @notice Returns the timestamp of the last update
    function lastUpdateTimestamp() external view returns (uint);

    /// @notice Returns the current average yield
    function averageYield() external view returns (int);

    /// @notice Returns the next update timestamp
    function nextUpdateTimestamp() external view returns (uint);

    /// @notice Returns the last conversion rate
    function lastConversionRate() external view returns (int);

    /// @notice Returns the last yield
    function lastYield() external view returns (int yield);

}