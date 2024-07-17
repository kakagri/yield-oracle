// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
import {IYieldBearingToken} from "./interfaces/IYieldBearingToken.sol";
import {IYieldOracle} from "./interfaces/IYieldOracle.sol";
import {YieldOracle} from "./YieldOracle.sol";
import {IYieldOracleFactory}  from "./interfaces/IYieldOracleFactory.sol";


/// @title YieldOracleFactory
/// @author Khaled G. @ Allez Labs
/// @custom:contact kh.grira@gmail.com
/// @notice Factory contract for creating YieldOracle contracts
contract YieldOracleFactory is IYieldOracleFactory {

    /// @inheritdoc IYieldOracleFactory
    mapping(address => bool) public isYieldOracle;

    /// @inheritdoc IYieldOracleFactory
    function createYieldOracle(
        IYieldBearingToken yieldBearingToken,
        uint interval,
        uint window,
        uint conversionSample,
        int scaleFactor,
        string memory description,
        bytes32 salt
    ) external returns (IYieldOracle oracle) {
        oracle = IYieldOracle(
            address(
                new YieldOracle{salt: salt}(
                    yieldBearingToken,
                    interval,
                    window,
                    conversionSample,
                    scaleFactor,
                    description
                )
            )
        );
        isYieldOracle[address(oracle)] = true;

        emit CreateYieldOracle(msg.sender, address(oracle), address(yieldBearingToken), interval, window);
    }
}