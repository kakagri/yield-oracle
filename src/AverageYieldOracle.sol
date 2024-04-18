// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {IYieldBearingToken} from "./interfaces/IYieldBearingToken.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {IAverageYieldOracle} from "./interfaces/IAverageYieldOracle.sol";
import {AutomationCompatibleInterface} from "chainlink/src/v0.8/automation/AutomationCompatible.sol";

/// @title AverageYieldOracle
/// @author Khaled G. @ Allez Labs
/// @custom:contact kh.grira@gmail.com
/// @notice This is a contract to compute average yield from on-chain conversion rates.
contract AverageYieldOracle is IAverageYieldOracle {

    /* Immutables */

    /// @inheritdoc IAverageYieldOracle
    IYieldBearingToken public immutable YIELD_BEARING_TOKEN;

    /// @inheritdoc IAverageYieldOracle
    uint public immutable INTERVAL; 

    /// @inheritdoc IAverageYieldOracle
    uint public immutable WINDOW;
    
    /// @inheritdoc IAverageYieldOracle
    uint public immutable CONVERSION_SAMPLE;
    
    /// @inheritdoc IAverageYieldOracle
    int public immutable SCALE_FACTOR; 

    /* Internal */
    
    mapping(uint => int) internal _conversionRates;
    uint internal counter;

    /* Public */

    /// @inheritdoc IAverageYieldOracle
    uint public lastUpdateTimestamp;

    /// @inheritdoc IAverageYieldOracle
    int public averageYield;

    /* Constructor */
    /// @param _yieldBearingToken The yield bearing token or a wrapper contract that implements the IYieldBearingToken interface to report an exchange rate
    /// @param _interval The rate of update interval
    /// @param _window The number of windows to store the exchange rates, 8 windows -> 7 APRs generated
    /// @param _conversionSample The conversion sample for the yield bearing token
    /// @param _scaleFactor The scaling factor to bring the yield to a given unit (WAD, RAY, etc.)
    constructor(
        IYieldBearingToken _yieldBearingToken,
        uint _interval,
        uint _window,
        uint _conversionSample,
        int _scaleFactor
    ) {
        if (address(_yieldBearingToken) == address(0)) revert ErrorsLib.YieldBearingTokenIsZeroAddress();
        if (_interval == 0) revert ErrorsLib.IntervalIsZero();
        if (_window < 2) revert ErrorsLib.WindowIsTooSmall();
        if (_conversionSample == 0) revert ErrorsLib.ConversionSampleIsZero();
        if (_scaleFactor == 0) revert ErrorsLib.ScaleFactorIsZero();
        
        YIELD_BEARING_TOKEN = _yieldBearingToken;
        INTERVAL = _interval;
        WINDOW = _window;
        CONVERSION_SAMPLE = _conversionSample;
        SCALE_FACTOR = _scaleFactor;
    }

    /// @inheritdoc AutomationCompatibleInterface
    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        return (block.timestamp >= lastUpdateTimestamp + INTERVAL, "");
    }

    /// @inheritdoc AutomationCompatibleInterface
    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        if (block.timestamp < lastUpdateTimestamp + INTERVAL) revert ErrorsLib.UpdateNotNeededYet(nextUpdateTimestamp());

        uint conversionRate = YIELD_BEARING_TOKEN.convertToAssets(CONVERSION_SAMPLE);
        _conversionRates[counter] = int256(conversionRate);
        counter = (counter + 1) % WINDOW;

        averageYield = _computeAverageYield();
        lastUpdateTimestamp = block.timestamp;

        emit AverageYieldUpdated(averageYield, conversionRate, lastUpdateTimestamp);
    }

    function _computeAverageYield() internal view returns(int256 yield) {
        for(uint k = 0; k < WINDOW - 2; k++) {
            yield += (_conversionRates[(counter + k + 1) % WINDOW] - _conversionRates[(counter + k) % WINDOW]) * SCALE_FACTOR / _conversionRates[(counter + k) % WINDOW];
        }
        yield = yield * 365 days / int256(INTERVAL * (WINDOW - 1));
    }

    /// @inheritdoc IAverageYieldOracle
    function nextUpdateTimestamp() public view returns(uint) {
        return lastUpdateTimestamp + INTERVAL;
    }

    /// @inheritdoc IAverageYieldOracle
    function lastConversionRate() external view returns(int) {
        return _conversionRates[(counter + WINDOW - 1) % WINDOW];
    }

    /// @inheritdoc IAverageYieldOracle
    function lastYield() external view returns(int yield) {
        yield = (_conversionRates[(counter + WINDOW -1) % WINDOW] - _conversionRates[(counter + WINDOW - 2) % WINDOW]) * SCALE_FACTOR / _conversionRates[(counter + WINDOW - 2) % WINDOW];
        yield = yield * 365 days / int256(INTERVAL);
    }

}


