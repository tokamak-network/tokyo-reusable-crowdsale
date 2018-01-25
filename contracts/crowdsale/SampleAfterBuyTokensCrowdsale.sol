pragma solidity ^0.4.18;

import "./BaseCrowdsale.sol";
import "./BlockIntervalCrowdsale.sol";
import "./PurchaseLimitedCrowdsale.sol";

/**
 * @title SampleAfterBuyTokensCrowdsale
 * @notice SampleAfterBuyTokensCrowdsale limit purchaser to take participate too frequently.
 */
contract SampleAfterBuyTokensCrowdsale is BaseCrowdsale, BlockIntervalCrowdsale, PurchaseLimitedCrowdsale {

  function SampleAfterBuyTokensCrowdsale(
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rate,
    uint256 _cap,
    uint256 _goal,
    address _vault,
    address _nextTokenOwner,
    uint256 _blockInterval,
    uint256 _purchaseLimit
    ) public
    BaseCrowdsale (
      _startTime,
      _endTime,
      _rate,
      _cap,
      _goal,
      _vault,
      _nextTokenOwner
      )
    BlockIntervalCrowdsale(_blockInterval)
    PurchaseLimitedCrowdsale(_purchaseLimit) {}
}
