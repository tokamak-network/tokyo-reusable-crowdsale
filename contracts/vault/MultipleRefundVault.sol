pragma solidity ^0.4.18;

import '../zeppelin/math/SafeMath.sol';
import '../zeppelin/crowdsale/RefundVault.sol';

/**
 * @title MultipleRefundVault
 * @dev This contract distribute ether to multiple address.
 */
contract MultipleRefundVault is RefundVault {
  using SafeMath for uint256;

  uint256 public ratioCoeff;

  struct Holder {
    address addr;
    bool received;
    uint256 ratio;
  }

  Holder[] holders;
  mapping (address => bool) isHolder;

  function MultipleRefundVault(address _wallet, uint256 _ratioCoeff) public RefundVault(_wallet) {
    require(_ratioCoeff != 0);
    ratioCoeff = _ratioCoeff;
  }

  function addHolder(address _addr, uint256 _ratio) public onlyOwner {
    require(state == State.Active);
    require(!isHolder[_addr]);
    require(_ratio < ratioCoeff);

    holders.push(Holder(_addr, false, _ratio));
    isHolder[_addr] = true;
  }

  function removeHolder(address _addr) public onlyOwner {
    require(state == State.Active);
    require(isHolder[_addr]);

    for (uint8 i = 0; i < holders.length; i++) {
      if (holders[i].addr == _addr) {
        delete holders[i];
        isHolder[_addr] = false;
        return;
      }
    }
  }

  function close() public onlyOwner {
    require(state == State.Active);

    distribute();

    super.close();
  }

  /**
   * @dev Distribute ether to `holder`s according to ratio.
   * Remaining ether is transfered to `wallet`.
   */
  function distribute() internal {
    uint256 balance = this.balance;

    for (uint8 = 0; i < holders.length; i++) {
      uint256 holderAmount = balance.mul(holders[i].ratio).div(ratioCoeff);

      holders[i].addr.transfer(holderAmount);
      holders[i].received = true;
    }
  }
}
