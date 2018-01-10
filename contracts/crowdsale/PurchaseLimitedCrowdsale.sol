pragma solidity ^0.4.18;

import "../zeppelin/crowdsale/Crowdsale.sol";
import "../zeppelin/ownership/Ownable.sol";

/**
 * @dev Limit a single purchaser from funding too many ether.
 */
contract PurchaseLimitedCrowdsale is Crowdsale {
  mapping (address => uint256) public purchaseFunded;
  uint256 public purchaseLimit;

  function PurchaseLimitedCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _purchaseLimit)
    public
    Crowdsale(_startTime, _endTime, _rate, _wallet) {
    require(_purchaseLimit != 0);
    purchaseLimit = _purchaseLimit;
  }

  function buyTokens(address beneficiary) public payable {
    super.buyTokens(beneficiary);
    purchaseFunded[msg.sender] = purchaseFunded[msg.sender].add(msg.value);
  }

  function validPurchase() internal view returns (bool) {
    bool underLimit = purchaseFunded[msg.sender].add(msg.value) <= purchaseLimit;
    return underLimit && super.validPurchase();
  }
}
