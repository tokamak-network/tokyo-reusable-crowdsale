pragma solidity ^0.4.18;

import "../zeppelin/crowdsale/Crowdsale.sol";
import "../zeppelin/ownership/Ownable.sol";

/**
 * @dev Token purchasing requires minimun ether.
 */
contract MinimunPurchasedCrowdsale is Crowdsale {
  uint256 minPurchase;

  function MinimunPurchasedCrowdsale(uint256 _minPurchase) public {
    require(minPurchase != 0);
    minPurchase = _minPurchase;
  }

  function validPurchase() internal view returns (bool) {
    bool overMinPurchase = msg.value >= minPurchase;
    return overMinPurchase && super.validPurchase();
  }
}
