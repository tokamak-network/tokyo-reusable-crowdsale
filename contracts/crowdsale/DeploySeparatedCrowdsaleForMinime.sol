pragma solidity ^0.4.18;

import '../zeppelin/crowdsale/RefundableCrowdsale.sol';
import '../minime/MiniMeToken.sol';

contract DeploySeparatedCrowdsaleForMinime is RefundableCrowdsale {

  MiniMeToken token;

  function DeploySeparatedCrowdsaleForMinime (
      address _vault,
      address _token,
      uint256 _startTime,
      uint256 _endTime,
      uint256 _rate,
      uint256 _goal
    ) {
      vault = RefundVault(_vault);
      token = MiniMeToken(_token);
      startTime = _startTime;
      endTime = _endTime;
      rate = _rate;
      goal = _goal;
    }
}
