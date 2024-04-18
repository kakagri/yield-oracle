// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
import {AverageYieldOracle} from "../AverageYieldOracle.sol";
import {IYieldBearingToken} from "./IYieldBearingToken.sol";

/// @title IAverageYieldOracleFactory
/// @author Khaled G. @ Allez Labs
/// @custom:contact kh.grira@gmail.com
/// @notice Interface for AverageYieldOracleFactory
interface IAverageYieldOracleFactory {
    /// @notice Emitted when a new average yield oracle is created
    /// @param caller Address of the caller
    /// @param yieldOracle Address of the yield oracle created
    event CreateAverageYieldOracle(address caller, address yieldOracle, IYieldBearingToken yieldBearingToken, uint interval, uint window);

    /// @notice Creates a new average yield oracle
    /// @param yieldBearingToken The yield bearing token or a wrapper contract that implements the IYieldBearingToken interface to report an exchange rate
    /// @param interval The rate of update interval
    /// @param window The number of windows to store the exchange rates, 8 windows -> 7 APRs generated
    /// @param conversionSample The conversion sample for the yield bearing token
    /// @param scaleFactor The scaling factor to bring the yield to a given unit (WAD, RAY, etc.)
    /// @param salt The salt used to deploy the oracle
    function createAverageYieldOracle(
        IYieldBearingToken yieldBearingToken,
        uint interval,
        uint window,
        uint conversionSample,
        int scaleFactor,
        bytes32 salt
    ) external returns (AverageYieldOracle oracle);

    /// @notice Checks if an address is an average yield oracle deployed through the factory
    function isAverageYieldOracle(address yieldOracle) external view returns (bool);
}