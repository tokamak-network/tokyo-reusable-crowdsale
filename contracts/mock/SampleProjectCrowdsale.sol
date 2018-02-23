pragma solidity^0.4.18;

import "../crowdsale/BaseCrowdsale.sol";
import "../crowdsale/MiniMeBaseCrowdsale.sol";
import "../crowdsale/BonusCrowdsale.sol";
import "../crowdsale/PurchaseLimitedCrowdsale.sol";
import "../crowdsale/MinimumPaymentCrowdsale.sol";
import "../crowdsale/BlockIntervalCrowdsale.sol";
import "../crowdsale/KYCCrowdsale.sol";
import "../crowdsale/StagedCrowdsale.sol";

contract SampleProjectCrowdsale is BaseCrowdsale, MiniMeBaseCrowdsale, BonusCrowdsale, PurchaseLimitedCrowdsale, MinimumPaymentCrowdsale, BlockIntervalCrowdsale, KYCCrowdsale, StagedCrowdsale {
  bool public initialized;

  // constructor parameters are left padded bytes32.

  function SampleProjectCrowdsale(bytes32[15] args)
    BaseCrowdsale(
      parseUint(args[0]),
      parseUint(args[1]),
      parseUint(args[2]),
      parseUint(args[3]),
      parseUint(args[4]),
      parseUint(args[5]),
      parseAddress(args[6]),
      parseAddress(args[7]),
      parseAddress(args[8]))
    MiniMeBaseCrowdsale(
      parseAddress(args[9]))
    BonusCrowdsale()
    PurchaseLimitedCrowdsale(
      parseUint(args[10]))
    MinimumPaymentCrowdsale(
      parseUint(args[11]))
    BlockIntervalCrowdsale(
      parseUint(args[12]))
    KYCCrowdsale(
      parseAddress(args[13]))
    StagedCrowdsale(
      parseUint(args[14])) public {}


  function parseBool(bytes32 b) internal pure returns (bool) {
    return b == 0x1;
  }

  function parseUint(bytes32 b) internal pure returns (uint) {
    return uint(b);
  }

  function parseAddress(bytes32 b) internal pure returns (address) {
    return address(b & 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff);
  }

  function init(bytes32[] args) external onlyOwner {
    require(!initialized);
    initialized = true;
  }
}
