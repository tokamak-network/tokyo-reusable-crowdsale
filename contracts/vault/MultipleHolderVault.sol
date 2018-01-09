pragma solidity ^0.4.18;

import '../zeppelin/math/SafeMath.sol';
import '../zeppelin/crowdsale/RefundVault.sol';
import '../common/HolderBase.sol';

/**
 * @title MultipleHolderVault
 * @dev This contract distribute ether to multiple address.
 */
contract MultipleHolderVault is HolderBase, RefundVault {
  using SafeMath for uint256;

  function MultipleHolderVault(address _wallet, uint256 _ratioCoeff)
    public
    HolderBase(_ratioCoeff)
    RefundVault(_wallet)
    {}

  function close() public onlyOwner {
    require(state == State.Active);

    super.distribute();

    super.close();
  }
}
