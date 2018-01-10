pragma solidity ^0.4.18;

import "../zeppelin/crowdsale/Crowdsale.sol";
import "../zeppelin/ownership/Ownable.sol";

/**
 * @dev Token purchasing requires minimun ether.
 */
contract MinimunPurchasedCrowdsale is Crowdsale {
  uint256 minPurchase;

  function MinimunPurchasedCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _minPurchase)
    public
    Crowdsale(_startTime, _endTime, _rate, _wallet) {
    require(minPurchase != 0);
    minPurchase = _minPurchase;
  }

  function validPurchase() internal view returns (bool) {
    bool overMinPurchase = msg.value >= minPurchase;
    return overMinPurchase && super.validPurchase();
  }
}
