pragma solidity ^0.4.18;

import "../zeppelin/crowdsale/Crowdsale.sol";
import "../zeppelin/ownership/Ownable.sol";

/**
 * @title MinimunPurchasedCrowdsale
 * @notice To buy tokens, purchaser should make payment with minimun amount of ether.
 */
contract MinimunPurchasedCrowdsale is Crowdsale {
  uint256 minPurchase;

  function MinimunPurchasedCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _minPurchase)
    public
    Crowdsale(_startTime, _endTime, _rate, _wallet) {
    require(minPurchase != 0);
    minPurchase = _minPurchase;
  }

  /**
   * @dev valid if msg.value is less than `minPurchase`.
   */
  function validPurchase() internal view returns (bool) {
    bool overMinPurchase = msg.value >= minPurchase;
    return overMinPurchase && super.validPurchase();
  }
}
