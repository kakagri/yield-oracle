// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
import {IYieldOracle} from "./IYieldOracle.sol";
import {IYieldBearingToken} from "./IYieldBearingToken.sol";

/// @title IYieldOracleFactory
/// @author Khaled G. @ Allez Labs
/// @custom:contact kh.grira@gmail.com
/// @notice Interface for YieldOracleFactory
interface IYieldOracleFactory {
    /// @notice Emitted when a new yield oracle is created
    /// @param caller Address of the caller
    /// @param yieldOracle Address of the yield oracle created
    event CreateYieldOracle(address caller, address yieldOracle, address yieldBearingToken, uint interval, uint window);

    /// @notice Creates a new yield oracle
    /// @param yieldBearingToken The yield bearing token or a wrapper contract that implements the IYieldBearingToken interface to report an exchange rate
    /// @param interval The rate of update interval
    /// @param window The number of windows to store the exchange rates, 8 windows -> 7 APRs generated
    /// @param conversionSample The conversion sample for the yield bearing token
    /// @param scaleFactor The scaling factor to bring the yield to a given unit (WAD, RAY, etc.)
    /// @param description The description for the oracle
    /// @param salt The salt used to deploy the oracle
    function createYieldOracle(
        IYieldBearingToken yieldBearingToken,
        uint interval,
        uint window,
        uint conversionSample,
        int scaleFactor,
        string memory description,
        bytes32 salt
    ) external returns (IYieldOracle oracle);

    /// @notice Checks if an address is a yield oracle deployed through the factory
    function isYieldOracle(address yieldOracle) external view returns (bool);
}