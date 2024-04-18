// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

/// @title Errors
/// @author Khaled G. @ Allez Labs
/// @custom:contact kh.grira@gmail.com
/// @notice Library for error messages
library ErrorsLib {
    /// @notice Yield bearing token address is zero address
    error YieldBearingTokenIsZeroAddress();

    /// @notice Conversion Rates length does not match window
    error ConversionRatesLengthMismatch();

    /// @notice Interval is zero
    error IntervalIsZero();

    /// @notice Window is smaller than 2
    error WindowIsTooSmall();

    /// @notice Conversion sample is zero
    error ConversionSampleIsZero();

    /// @notice Scale factor is zero
    error ScaleFactorIsZero();

    /// @notice Last timestamp is zero
    error LastUpdateTimestampIsZero();

    /// @notice Updated not needed yet
    error UpdateNotNeededYet(uint nextUpdate);
}