pragma solidity ^0.4.18;

import "../zeppelin/crowdsale/RefundableCrowdsale.sol";

contract HookedCrowdsale is RefundableCrowdsale {

  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    buyTokensPreHook(beneficiary);
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

    buyTokensPostHook(beneficiary);
  }

  function finalization() internal {
    if (goalReached()) {
      vault.close();
      finalizationSuccessHook();
    } else {
      vault.enableRefunds();
      finalizationFailHook();
    }

    super.finalization();
  }

  function calculateToFund(uint256 _weiAmount) internal view returns (uint256);

  function buyTokensPreHook(address _beneficiary) internal;
  function buyTokensPostHook(address _beneficiary) internal;
  function finalizationFailHook() internal;
  function finalizationSuccessHook() internal;

  function tokenGeneration(address _beneficiary, uint256 _tokens) internal;
  function transferTokenOwnership() internal;

  function forwardFunds(uint256 toFund) internal {
    vault.deposit.value(toFund)(msg.sender);
  }
}
