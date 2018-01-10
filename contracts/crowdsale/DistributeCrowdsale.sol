pragma solidity ^0.4.18;

import "../zeppelin/crowdsale/Crowdsale.sol";
import "../common/HolderBase.sol";

/**
 * @title DistributeCrowdsale
 * @notice DistributeCrowdsale distributes crowdsale's token to token holders.
 *  Use MultiHolderVault to distribute ether.
 */
contract DistributeCrowdsale is HolderBase, Crowdsale {
  function DistributeCrowdsale(uint256 _ratioCoeff, uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet)
    public
    HolderBase(_ratioCoeff)
    Crowdsale(_startTime, _endTime, _rate, _wallet) {}
}
