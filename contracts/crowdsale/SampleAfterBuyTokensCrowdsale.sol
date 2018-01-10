pragma solidity ^0.4.18;

import "../zeppelin/crowdsale/Crowdsale.sol";
import "./BlockIntervalCrowdsale.sol";
import "./PurchaseLimitedCrowdsale.sol";

/**
 * @title SampleAfterBuyTokensCrowdsale
 * @notice SampleAfterBuyTokensCrowdsale limit purchaser to take participate too frequently.
 */
contract SampleAfterBuyTokensCrowdsale is Crowdsale, BlockIntervalCrowdsale, PurchaseLimitedCrowdsale {

  function SampleAfterBuyTokensCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _blockInterval, uint256 _purchaseLimit)
    public
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    BlockIntervalCrowdsale(_startTime, _endTime, _rate, _wallet, _blockInterval)
    PurchaseLimitedCrowdsale(_startTime, _endTime, _rate, _wallet, _purchaseLimit) {}

  /**
   * @notice save block number condition after call super.buyTokens function.
   */
  function buyTokens(address beneficiary) public payable {
    Crowdsale.buyTokens(beneficiary);
    BlockIntervalCrowdsale.afterBuyTokens();
    PurchaseLimitedCrowdsale.afterBuyTokens();
  }
}
