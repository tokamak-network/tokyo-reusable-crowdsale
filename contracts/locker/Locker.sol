pragma solidity ^0.4.18;

import '../zeppelin/math/SafeMath.sol';
import '../zeppelin/ownership/Ownable.sol';
import '../zeppelin/token/ERC20/SafeERC20.sol';

/**
 * @title Locker
 * @dev Locker holds tokens and releases them at a certain time.
 */
contract Locker is Ownable {
  using SafeMath for uint;
  using SafeERC20 for ERC20Basic;

  /**
   * It is init state only when adding release info is possible.
   * beneficiary only can release tokens when Locker is active.
   * After all tokens are released, locker is drawn.
   */
  enum State { Init, Ready, Active, Drawn }

  struct Beneficiary {
    uint ratio;             // ratio based on Locker's initial balance.
    uint withdrawAmount;    // accumulated tokens beneficiary released
    bool releaseAllTokens;
  }

  /**
   * @notice Release has info to release tokens.
   * If lock type is straight, only two release infos is required.
   *
   *     |
   * 100 |                _______________
   *     |              _/
   *  50 |            _/
   *     |         . |
   *     |       .   |
   *     |     .     |
   *     +===+=======+----*----------> time
   *     Locker  First    Second
   *  Activated  Release  Release
   *
   *
   * If lock type is variable, the release graph will be
   *
   *     |
   * 100 |                                 _________
   *     |                                |
   *  70 |                      __________|
   *     |                     |
   *  30 |            _________|
   *     |           |
   *     +===+=======+---------+----------*------> time
   *     Locker   First        Second     Last
   *  Activated   Release      Release    Release
   *
   *
   *
   * For the first straight release graph, parameters would be
   *   coeff: 100
   *   releaseTimes: [
   *     first release time,
   *     second release time
   *   ]
   *   releaseRatios: [
   *     50,
   *     100,
   *   ]
   *
   * For the second variable release graph, parameters would be
   *   coeff: 100
   *   releaseTimes: [
   *     first release time,
   *     second release time,
   *     last release time
   *   ]
   *   releaseRatios: [
   *     30,
   *     70,
   *     100,
   *   ]
   *
   */
  struct Release {
    bool isStraight;        // lock type : straight or variable
    uint[] releaseTimes;    //
    uint[] releaseRatios;   //
  }



  uint public activeTime;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  uint public coeff;
  uint public initialBalance;
  uint public withdrawAmount; // total amount of tokens released

  mapping (address => Beneficiary) beneficiaries;
  mapping (address => Release) releases;  // beneficiary's lock
  mapping (address => bool) locked; // whether beneficiary's lock is instantiated

  uint public numBeneficiaries;
  uint public numLocks;

  State public state;

  modifier onlyState(State v) {
    require(state == v);
    _;
  }

  modifier onlyBeneficiary(address _addr) {
    require(beneficiaries[_addr].ratio > 0);
  }

  function Locker(uint _coeff, address[] _beneficiaries, uint[] _ratios) public {
    require(_coeff > 0);
    require(_beneficiaries.length == _ratios.length);

    numBeneficiaries = _beneficiaries.length;

    uint accRatio;

    for(uint i = 0; i < _beneficiaries.length; i++) {
      beneficiaries[_beneficiaries[i]] = Beneficiary({
        ratio: _ratios[i],
        withdrawAmount: 0,
        releaseAllTokens: false
      });

      accRatio = accRatio.add(_ratios[i]);
    }

    require(coeff == accRatio);
  }

  /**
   * @notice beneficiary can release their tokens after activated
   */
  function activate() external onlyOwner onlyState(State.Ready) {
    require(numLocks == numBeneficiaries); // double check : assert all releases are recorded

    initialBalance = token.balanceOf(this);
    require(initialBalance > 0);

    activeTime = now;

    // set locker as active state
    state = State.Active;
  }

  function lock(address _beneficiary, bool _isStraight, uint[] _releaseTimes, uint[] _releaseRatios)
    external
    onlyOwner
    onlyState(State.Init)
    onlyBeneficiary(_beneficiary)
  {
    require(!locked[_beneficiary]);
    require(_releaseRatios.length == _releaseTimes.length);

    uint len = _releaseRatios.length;

    require(_releaseRatios[len - 1] == coeff); // finally should release all tokens

    for(uint i = 0; i < len - 1; i++) { // check two array are ascending sorted
      require(_releaseTimes[i] < _releaseTimes[i + 1]);
      require(_releaseRatios[i] < _releaseRatios[i + 1]);
    }

    if (_isStraight) {
      require(len == 2); // 2 release times for straight locking type
    }

    locked[_beneficiary] = true;

    numLocks = numLocks.add(1);

    // create Release for the beneficiary
    releases[_beneficiary] = Release({
      isStraight: _isStraight,
      releaseTimes: _releaseTimes,
      releaseRatios: _releaseRatios
    });

    //  if all beneficiaries locked, change Locker state to change
    if (numLocks == numBeneficiaries) {
      state = State.Ready;
    }
  }

  /**
   * @dev release releasable tokens to beneficiary
   */
  function release() external onlyState(State.Active) onlyBeneficiary(_beneficiary) {
    require(!beneficiaries[_beneficiary].releaseAllTokens);

    uint releasableAmount = getReleasableAmount(msg.sender);
    beneficiaries[_beneficiary].releaseAmount = beneficiaries[_beneficiary].releaseAmount.add(releasableAmount);

    beneficiaries[_beneficiary].releaseAllTokens = beneficiaries[_beneficiary].releaseAmount == getPartialAmount(
        beneficiaries[_beneficiary].ratio,
        coeff,
        initialBalance);

    withdrawAmount = withdrawAmount.add(releasableAmount);

    if (withdrawAmount == initialBalance) {
      state = State.Drawn;
    }

    token.transfer(msg.sender, releasableAmount);
  }

  function getReleasableAmount(address _beneficiary) public view returns (uint) {
    if (beneficiaries[_beneficiary].isStraight) {
      return getStraightReleasableAmount(_beneficiary);
    } else {
      return getVariableReleasableAmount(_beneficiary);
    }
  }

  function getStraightReleasableAmount(address _beneficiary) internal returns (uint releasableAmount) {
    Beneficiary memory _b = beneficiaries[_beneficiary];
    Release memory _r = releases[_beneficiary];

    // total amount of tokens beneficiary will receive
    uint totalReleasableAmount = getPartialAmount(_b.ratio, coeff, initialBalance);

    uint firstTime = _r.releaseTimes[0];
    uint secondTime = _r.releaseTimes[1];

    require(now < firstTime); // pass if can release

    releasableAmount = getPartialAmount(
      now.sub(activeTime),
      secondTime.sub(activeTime),
      totalReleasableAmount);
    releasableAmount = releasableAmount.sub(_b.withdrawAmount);
  }

  function getVariableReleasableAmount(address _beneficiary) internal returns (uint releasableAmount) {
    Beneficiary memory _b = beneficiaries[_beneficiary];
    Release memory _r = releases[_beneficiary];

    // total amount of tokens beneficiary will receive
    uint totalReleasableAmount = getPartialAmount(_b.ratio, coeff, initialBalance);

    uint releaseRatio;

    for(uint i = 0; i < _r.releaseTimes.length; i++) {
      if (now > _r.releaseTimes[i]) {
        releaseRatio = _r.releaseRatios[i];
      }
    }

    require(releaseRatio > 0);

    releasableAmount = getPartialAmount(
      releaseRatio,
      coeff,
      totalReleasableAmount);
    releasableAmount = releasableAmount.sub(_b.withdrawAmount);
  }

  /// https://github.com/0xProject/0x.js/blob/05aae368132a81ddb9fd6a04ac5b0ff1cbb24691/packages/contracts/src/current/protocol/Exchange/Exchange.sol#L497
  /// @dev Calculates partial value given a numerator and denominator.
  /// @param numerator Numerator.
  /// @param denominator Denominator.
  /// @param target Value to calculate partial of.
  /// @return Partial value of target.
  function getPartialAmount(uint numerator, uint denominator, uint target) public pure returns (uint) {
    return numerator.mul(target).div(denominator);
  }
}
