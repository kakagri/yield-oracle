// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
import {IYieldBearingToken} from "./interfaces/IYieldBearingToken.sol";
import {AverageYieldOracle} from "./AverageYieldOracle.sol";
import {IAverageYieldOracleFactory}  from "./interfaces/IAverageYieldOracleFactory.sol";


/// @title AverageYieldOracleFactory
/// @author Khaled G. @ Allez Labs
/// @custom:contact kh.grira@gmail.com
/// @notice Factory contract for creating AverageYieldOracle contracts
contract AverageYieldOracleFactory is IAverageYieldOracleFactory {

    /// @inheritdoc IAverageYieldOracleFactory
    mapping(address => bool) public isAverageYieldOracle;

    /// @inheritdoc IAverageYieldOracleFactory
    function createAverageYieldOracle(
        IYieldBearingToken yieldBearingToken,
        uint interval,
        uint window,
        uint conversionSample,
        int scaleFactor,
        bytes32 salt
    ) external returns (AverageYieldOracle oracle) {
        oracle = new AverageYieldOracle{salt: salt}(
            yieldBearingToken,
            interval,
            window,
            conversionSample,
            scaleFactor
        );
        isAverageYieldOracle[address(oracle)] = true;

        emit CreateAverageYieldOracle(msg.sender, address(oracle), yieldBearingToken, interval, window);
    }
}