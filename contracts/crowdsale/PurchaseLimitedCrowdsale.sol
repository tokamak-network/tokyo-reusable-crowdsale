pragma solidity ^0.4.18;

import "./BaseCrowdsale.sol";

/**
 * @title PurchaseLimitedCrowdsale
 * @notice Limit a single purchaser from funding too many ether.
 */
contract PurchaseLimitedCrowdsale is BaseCrowdsale {
  mapping (address => uint256) public purchaseFunded;
  uint256 public purchaseLimit;

  function PurchaseLimitedCrowdsale(uint256 _purchaseLimit) public {
    require(_purchaseLimit != 0);
    purchaseLimit = _purchaseLimit;
  }

  function buyTokensPreHook(address _beneficiary, uint256 _toFund) internal {
    bool underLimit = purchaseFunded[_beneficiary].add(_toFund) <= purchaseLimit;
    require(underLimit);

    purchaseFunded[_beneficiary] = purchaseFunded[_beneficiary].add(_toFund);
  }
}
