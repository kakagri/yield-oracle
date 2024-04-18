// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.21;
import {IYieldBearingToken} from "../../src/interfaces/IYieldBearingToken.sol";

interface IWstETHLike { 
    function getStETHByWstETH(uint _wstETHAmount) external view returns (uint);
}

/// @title WstETHAdapterEthereum
/// @author Khaled G. @ Allez Labs
/// @custom:contact kh.grira@gmail.com
/// @notice This is an adapter for wstETH on Ethereum to make it an IYieldBearingToken and implement convertToAssets
contract WstETHAdapterEthereum is IYieldBearingToken {
    IWstETHLike public immutable WSTETH;
    
    constructor(
        address _wstETH
    ) {
        WSTETH = IWstETHLike(_wstETH);
    }

    /// @inheritdoc IYieldBearingToken
    function convertToAssets(uint256 shares) external view returns (uint256) {
        return WSTETH.getStETHByWstETH(shares);
    }
}