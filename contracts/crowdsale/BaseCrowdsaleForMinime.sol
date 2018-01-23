pragma solidity ^0.4.18;

import "./BaseCrowdsale.sol";
import "./DeploySeparatedCrowdsaleForMinime.sol";

contract BaseCrowdsaleForMinime is BaseCrowdsale, DeploySeparatedCrowdsaleForMinime {

  address nextTokenOwner;

  function BaseCrowdsaleForMinime (
    address _vault,
    address _token,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rate,
    uint256 _goal,
    uint256 _cap,
    address _nextTokenOwner
    ) DeploySeparatedCrowdsaleForMinime (
      _vault,
      _token,
      _startTime,
      _endTime,
      _rate,
      _goal
      ) CappedCrowdsale (_cap) {
        nextTokenOwner = _nextTokenOwner;
      }

  function tokenGeneration(address _beneficiary, uint256 _tokens) internal {
    token.generateTokens(_beneficiary, _tokens);
  }

  function transferTokenOwnership() internal {
    token.changeController(nextTokenOwner);
  }
}
