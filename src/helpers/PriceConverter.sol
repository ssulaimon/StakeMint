//SPDX-License-Identfier:MIT
pragma solidity >=0.8.0 <0.9.0;
import {AggregatorV3Interface} from "../../src/interfaces/IAggregatorV3Interface.sol";

library PriceConverter {
    function getCurrentAssetPrice(
        address priceFeedAddress
    ) public view returns (uint256) {
        AggregatorV3Interface aggregatorV3 = AggregatorV3Interface(
            priceFeedAddress
        );
        (, int256 answer, , , ) = aggregatorV3.latestRoundData();
        return uint256(answer) * 10e10;
    }

    function valueConverter(
        uint256 _value,
        address _priceFeedAddress
    ) public view returns (uint256) {
        uint256 latestPrice = getCurrentAssetPrice(_priceFeedAddress);
        uint256 value = latestPrice * _value;
        return value;
    }
}
