// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {IYieldBearingToken} from "./interfaces/IYieldBearingToken.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {IYieldOracle} from "./interfaces/IYieldOracle.sol";
import {AutomationCompatibleInterface} from "chainlink/src/v0.8/automation/AutomationCompatible.sol";

/// @title YieldOracle
/// @author Khaled G. @ Allez Labs
/// @custom:contact kh.grira@gmail.com
/// @notice This is a contract to compute average yield from on-chain conversion rates.
contract YieldOracle is IYieldOracle {

    /* Immutables */

    /// @inheritdoc IYieldOracle
    IYieldBearingToken public immutable YIELD_BEARING_TOKEN;

    /// @inheritdoc IYieldOracle
    uint public immutable INTERVAL; 

    /// @inheritdoc IYieldOracle
    uint public immutable WINDOW;
    
    /// @inheritdoc IYieldOracle
    uint public immutable CONVERSION_SAMPLE;
    
    /// @inheritdoc IYieldOracle
    int public immutable SCALE_FACTOR; 

    /// @inheritdoc IYieldOracle
    string public description;


    /* Internal */
    
    mapping(uint => int) public conversionRates;
    uint internal counter;

    /* Public */

    /// @inheritdoc IYieldOracle
    uint public lastUpdateTimestamp;

    /// @inheritdoc IYieldOracle
    int public yield;

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
        int _scaleFactor,
        string memory _description
    ) {
        if (address(_yieldBearingToken) == address(0)) revert ErrorsLib.YieldBearingTokenIsZeroAddress();
        if (_interval == 0) revert ErrorsLib.IntervalIsZero();
        if (_window < 2) revert ErrorsLib.WindowIsTooSmall();
        if (_conversionSample == 0) revert ErrorsLib.ConversionSampleIsZero();
        if (_scaleFactor == 0) revert ErrorsLib.ScaleFactorIsZero();

        for(uint k = 0; k < _window; k++) conversionRates[k] = 1;
        
        YIELD_BEARING_TOKEN = _yieldBearingToken;
        INTERVAL = _interval;
        WINDOW = _window;
        CONVERSION_SAMPLE = _conversionSample;
        SCALE_FACTOR = _scaleFactor;
        description = _description;
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
        conversionRates[counter] = int256(conversionRate);
        counter = (counter + 1) % WINDOW;

        yield = _computeYield();
        lastUpdateTimestamp = block.timestamp;

        emit YieldUpdated(yield, conversionRate, lastUpdateTimestamp);
    }

    function _computeYield() internal view returns(int256 yield_) {
        for(uint k = 0; k < WINDOW - 2; k++) {
            yield_ += (conversionRates[(counter + k + 1) % WINDOW] - conversionRates[(counter + k) % WINDOW]) * SCALE_FACTOR * 365.25 days / conversionRates[(counter + k) % WINDOW];
        }
        yield_ = yield_  / int256(INTERVAL * (WINDOW - 1));
    }

    /// @inheritdoc IYieldOracle
    function nextUpdateTimestamp() public view returns(uint) {
        return lastUpdateTimestamp + INTERVAL;
    }

    /// @inheritdoc IYieldOracle
    function lastConversionRate() external view returns(int) {
        return conversionRates[(counter + WINDOW - 1) % WINDOW];
    }

    /// @inheritdoc IYieldOracle
    function lastYield() external view returns(int yield_) {
        yield_ = (conversionRates[(counter + WINDOW -1) % WINDOW] - conversionRates[(counter + WINDOW - 2) % WINDOW]) * SCALE_FACTOR / conversionRates[(counter + WINDOW - 2) % WINDOW];
        yield_ = yield_ * 365.25 days / int256(INTERVAL);
    }

}


