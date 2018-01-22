pragma solidity ^0.4.18;

import "../zeppelin/crowdsale/Crowdsale.sol";

/**
 * @title HookedCrowdsale
 * @notice HookedCrowdsale calls afterBuyTokens function just after
 * Crowdsale.buyTokens function called
 */
contract HookedCrowdsale is Crowdsale {
  uint256 public blockInterval;
  mapping (address => uint256) public recentBlock;

  /**
   * @notice link post hook with buyTokens funciton.
   */
  function buyTokens(address beneficiary) public payable {
    super.buyTokens(beneficiary);
    afterBuyTokens(beneficiary);
  }

  /**
   * @notice abstract hooking function
   */
  function afterBuyTokens(address beneficiary) internal;
}
