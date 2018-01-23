pragma solidity ^0.4.18;

import "./BaseCrowdsale.sol";
import "../kyc/KYC.sol";

contract KYCCrowdsale {

  KYC kyc;

  function KYCCrowdsale (address _kyc) {
    require(_kyc != 0x0);
    kyc = KYC(_kyc);
  }

  function buyTokensHook(address _beneficiary) internal {
    require(kyc.registeredAddress(_beneficiary));
  }
}
