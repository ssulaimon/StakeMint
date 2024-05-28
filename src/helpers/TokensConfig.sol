//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {MyToken} from "../../src/MyToken.sol";
import {Test} from "forge-std/Test.sol";
import {Users} from "../../src/helpers/Users.sol";
import {MockV3Aggregator} from "../../src/mock/MockV3Aggregator.sol";

/**
All price feed are in ASSET/USD
 */

contract TokensConfig is Test, Users {
    struct Tokens {
        string name;
        address contractAddress;
        address priceFeedContract;
    }

    Tokens[] tokens;
    uint256 public constant TOKENS_SUPPLY = 200_000_000e18;
    string[] tokensNames = ["WrappedEth", "USDC", "Link"];
    string[] tokensSymbol = ["WETH", "USDC", "LINK"];
    int256[] startingPrice = [int256(3900e8), int256(1e18), int256(1820200000)];

    constructor() {
        if (block.chainid == 11155111) {
            sepoliaTokenConfiguration();
        } else {
            anvilTokenConfiguration();
        }
    }

    function sepoliaTokenConfiguration() private {
        //using ether pricefeed contract for wrapped eth price
        Tokens memory wrappedEth = Tokens({
            name: "WETH",
            contractAddress: 0xC558DBdd856501FCd9aaF1E62eae57A9F0629a3c,
            priceFeedContract: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        Tokens memory usdc = Tokens({
            name: "USDC",
            contractAddress: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8,
            priceFeedContract: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E
        });
        Tokens memory link = Tokens({
            name: "LINK",
            contractAddress: 0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5,
            priceFeedContract: 0xc59E3633BAAC79493d908e63626716e204A45EdF
        });
        tokens.push(wrappedEth);
        tokens.push(usdc);
        tokens.push(link);
    }

    function anvilTokenConfiguration() private {
        if (tokens.length == 0) {
            vm.startPrank(i_owner);

            for (uint index = 0; index < tokensNames.length; index++) {
                MyToken mockToken = new MyToken(
                    tokensNames[index],
                    tokensSymbol[index],
                    18,
                    TOKENS_SUPPLY
                );
                MockV3Aggregator priceFeed = new MockV3Aggregator(
                    8,
                    startingPrice[index]
                );
                Tokens memory config = Tokens({
                    name: tokensNames[index],
                    contractAddress: address(mockToken),
                    priceFeedContract: address(priceFeed)
                });
                tokens.push(config);
            }

            vm.stopPrank();
        }
    }

    function getTokens() public view returns (Tokens[] memory) {
        return tokens;
    }
}
