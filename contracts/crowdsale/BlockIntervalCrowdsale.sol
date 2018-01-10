pragma solidity ^0.4.18;

import "../zeppelin/crowdsale/Crowdsale.sol";

/**
 * @title BlockIntervalCrowdsale
 * @notice BlockIntervalCrowdsale limit purchaser to take participate too frequently.
 */
contract BlockIntervalCrowdsale is Crowdsale {
  uint256 public blockInterval;
  mapping (address => uint256) recentBlock;

  function BlockIntervalCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _blockInterval)
    public
    Crowdsale(_startTime, _endTime, _rate, _wallet) {
      require(_blockInterval != 0);
      blockInterval = _blockInterval;
    }

  /**
   * @notice save block number condition after call super.buyTokens function.
   */
  function buyTokens(address beneficiary) public payable {
    super.buyTokens(beneficiary);
    recentBlock[msg.sender] = block.number;
  }

  /**
   * @return true if the block number is over the block internal.
   */
  function validPurchase() internal view returns (bool) {
    bool withinBlock = recentBlock[msg.sender].add(blockInterval) < block.number;
    return withinBlock && super.validPurchase();
  }

  function afterBuyTokens() internal {
    recentBlock[msg.sender] = block.number;
  }
}
