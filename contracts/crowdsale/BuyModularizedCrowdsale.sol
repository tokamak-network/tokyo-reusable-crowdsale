pragma solidity ^0.4.18;

import "../zeppelin/crowdsale/Crowdsale.sol";

contract BuyModularizedCrowdsale is Crowdsale {

  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    buyTokensHook(beneficiary);
    uint256 weiAmount = msg.value;

    uint256 toFund = calculateToFund(weiAmount);
    uint256 toReturn = weiAmount.sub(toFund);

    // calculate token amount to be created
    uint256 tokens = getTokenAmount(toFund);

    // update state
    weiRaised = weiRaised.add(toFund);

    if (toReturn > 0) {
      msg.sender.transfer(toReturn);
    }

    tokenGeneration(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, toFund, tokens);

    forwardFunds(toFund);
  }

  function calculateToFund(uint256 _weiAmount) internal view returns (uint256);
  function tokenGeneration(uint256 _beneficiary, uint256 _tokens) internal;
  function buyTokensHook(address _beneficiary) internal;

  function forwardFunds(uint256 toFund) internal {
    vault.deposit.value(toFund)(msg.sender);
  }
}
