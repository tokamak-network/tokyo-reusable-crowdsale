pragma solidity ^0.4.18;

import "./BaseCrowdsale.sol";
import "../common/HolderBase.sol";

/**
 * @title DistributeCrowdsale
 * @notice DistributeCrowdsale distributes crowdsale's token to token holders.
 *  Use MultiHolderVault to distribute ether.
 */
contract DistributeCrowdsale is HolderBase, BaseCrowdsale {
  function DistributeCrowdsale(uint256 _ratioCoeff) public
    HolderBase(_ratioCoeff) {}
}
