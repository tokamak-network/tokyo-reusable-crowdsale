pragma solidity ^0.4.18;

import "../zeppelin/crowdsale/Crowdsale.sol";
import "../zeppelin/ownership/Ownable.sol";

/**
 * @title MinimunPaymentCrowdsale
 * @notice To buy tokens, purchaser should make payment with minimun amount of ether.
 */
contract MinimunPaymentCrowdsale is Crowdsale {
  uint256 minPayment;

  function MinimunPaymentCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _minPayment)
    public
    Crowdsale(_startTime, _endTime, _rate, _wallet) {
    require(minPayment != 0);
    minPayment = _minPayment;
  }

  /**
   * @return true if msg.value is less than `minPayment`.
   */
  function validPayment() internal view returns (bool) {
    bool overMinPayment = msg.value >= minPayment;
    return overMinPayment && super.validPayment();
  }
}
