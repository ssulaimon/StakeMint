//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

interface IStakeMint {
    function withdraw() external returns (bool);

    function deposit(
        uint256 _value,
        uint256 _assetIndex
    ) external returns (bool);
    function addAsset(
        string calldata _name,
        address _assetContractAdress,
        address _assetPriceFeed
    ) external returns (bool);

    function checkContractTotalValueLocked() external view returns (uint256);

    function getContractAssetValueLocked(
        address asset
    ) external view returns (uint256);

    function getUserTotalValueLocked(
        address _user
    ) external view returns (uint256);
    function getUserAssetValueLocked(
        address _user,
        address _asset
    ) external view returns (uint256);
}
