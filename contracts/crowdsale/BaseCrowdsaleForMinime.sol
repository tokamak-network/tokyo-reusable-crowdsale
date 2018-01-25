pragma solidity ^0.4.18;

import "./BaseCrowdsale.sol";
import "../minime/MiniMeToken.sol";

contract BaseCrowdsaleForMinime is BaseCrowdsale {

  MiniMeToken token;

  function BaseCrowdsaleForMinime (
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rate,
    uint256 _cap,
    uint256 _goal,
    address _vault,
    address _nextTokenOwner,
    address _token
    ) BaseCrowdsale (
      _startTime,
      _endTime,
      _rate,
      _cap,
      _goal,
      _vault,
      _nextTokenOwner
      ) {
        require(_token != address(0));
        token = MiniMeToken(_token);
      }


  function generateToken(address _beneficiary, uint256 _tokens) internal {
    token.generateTokens(_beneficiary, _tokens);
  }

  function transferTokenOwnership(address _to) internal {
    token.changeController(_to);
  }

}
