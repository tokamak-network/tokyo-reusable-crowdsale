pragma solidity ^0.4.18;

import '../zeppelin/math/SafeMath.sol';
import '../zeppelin/ownership/Ownable.sol';

/**
 * @title HolderBase
 * @dev This contract handler token / ether holder.
 */
contract HolderBase is Ownable {
  using SafeMath for uint256;

  uint256 public ratioCoeff;

  struct Holder {
    address addr;
    uint256 ratio;
  }

  Holder[] public holders;

  function HolderBase(uint256 _ratioCoeff) public {
    require(_ratioCoeff != 0);
    ratioCoeff = _ratioCoeff;
  }

  function getHolderCount() public view returns (uint256) {
    return holders.length;
  }

  function initHolders(address[] _addrs, uint256[], _ratios) public onlyOwner {
    require(holders.length == 0);
    require(_addrs.length == _ratios.length);
    uint256 accRatio;

    for(uint8 i = 0; i < _addrs.length; i++) {
      holders.push(Holder(_addrs[i], _ratios[i]));
      accRatio = accRatio.add(holders[i].ratio);
    }

    require(accRatio <= ratioCoeff);
  }

  /**
   * @dev Distribute ether to `holder`s according to ratio.
   * Remaining ether is transfered to `wallet` from the close
   * function of RefundVault contract.
   */
  function distribute() internal {
    uint256 balance = this.balance;

    for (uint8 i = 0; i < holders.length; i++) {
      uint256 holderAmount = balance.mul(holders[i].ratio).div(ratioCoeff);

      holders[i].addr.transfer(holderAmount);
    }
  }
}
