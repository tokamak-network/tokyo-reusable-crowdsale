pragma solidity ^0.4.18;

import "./BaseCrowdsale.sol";
import "../kyc/KYC.sol";

contract KYCCrowdsale is BaseCrowdsale {

  KYC kyc;

  function KYCCrowdsale (address _kyc) public {
    require(_kyc != 0x0);
    kyc = KYC(_kyc);
  }

  function buyTokensPreHook(address _beneficiary, uint256 _toFund) internal {
    require(kyc.registeredAddress(_beneficiary));
  }
}
