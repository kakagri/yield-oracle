// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;


/// @title IYieldBearingToken
/// @author Khaled G. @ Allez Labs
/// @custom:contact kh.grira@gmail.com
/// @notice Interface for yield bearing token
interface IYieldBearingToken {
    /**
     * @notice Get amount of underlying token for one yield bearing token: e.g. amount of stETH for 1 wstETH, or amount of DAI for 1 sDAI
     * @return Amount of underlying token for 1 yield bearing token
     */
    function convertToAssets(uint256 shares) external view returns (uint256);
}