pragma solidity ^0.4.18;

import "./BuyModularizedCrowdsale.sol";
import "./DeploySeparatedCrowdsale.sol";
import "../zeppelin/crowdsale/CappedCrowdsale.sol";

contract BaseCrowdsale is BuyModularizedCrowdsale, DeploySeparatedCrowdsale, CappedCrowdsale {

  address nextTokenOwner;

  function BaseCrowdsale (
    address _vault,
    address _token,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rate,
    uint256 _goal,
    uint256 _cap,
    address _nextTokenOwner
    ) DeploySeparatedCrowdsale (
      _vault,
      _token,
      _startTime,
      _endTime,
      _rate,
      _goal
      ) CappedCrowdsale (_cap) {}

  function calculateToFund(uint256 _weiAmount) internal view returns (uint256) {
    uint256 toFund;
    uint256 postWeiRaised = weiRaised.add(_weiAmount);

    if (postWeiRaised > cap) {
      toFund = cap.sub(weiRaised);
    } else {
      toFund = _weiAmount;
    }
    return toFund;
  }

  function tokenGeneration(uint256 _beneficiary, uint256 _tokens) internal {
    token.mint(_beneficiary, _tokens);
  }

  function validPurchase() internal view returns (bool) {
    bool withinCap = weiRaised <= cap;
    return withinCap && BuyModularizedCrowdsale.validPurchase();
  }
}
