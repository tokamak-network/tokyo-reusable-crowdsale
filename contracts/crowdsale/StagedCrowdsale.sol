pragma solidity ^0.4.18;

import "./KYCCrowdsale.sol";

/**
 * @title StagedCrowdsale
 * @notice StagedCrowdsale seperates sale period with start time & end time.
 * For each period, seperate max cap and kyc could be setup.
 * Both startTime and endTime are inclusive.
 */
contract StagedCrowdsale is KYCCrowdsale {

  uint8 public MAX_PERIODS_COUNT;

  Period[] public periods;

  struct Period {
    uint128 cap;
    uint128 maxPurchaseLimit;
    uint128 minPurchaseLimit;
    uint128 weiRaised; // stage's wei raised
    uint32 startTime;
    uint32 endTime;
    bool kyc;
  }

  function StagedCrowdsale(uint _MAX_PERIODS_COUNT) public {
    MAX_PERIODS_COUNT = uint8(_MAX_PERIODS_COUNT);
  }

  function initPeriods(
    uint32[] _startTimes,
    uint32[] _endTimes,
    uint128[] _caps,
    uint128[] _maxPurchaseLimits,
    uint128[] _minPurchaseLimits,
    bool[] _kycs)
    public
  {
    uint len = _startTimes.length;

    require(periods.length == 0); // one time init
    require(len == _startTimes.length
      && len == _endTimes.length
      && len == _caps.length
      && len == _maxPurchaseLimits.length
      && len == _minPurchaseLimits.length
      && len == _kycs.length);

    uint periodCap;

    for (uint i = 0; i < _startTimes.length; i++) {
      if (_caps[i] != 0) {
        periodCap = coeff.add(uint(_caps[i])).mul(uint(cap)).div(coeff);
      } else {
        periodCap = 0;
      }

      periods.push(Period({
        startTime: _startTimes[i],
        endTime: _endTimes[i],
        cap: uint128(periodCap),
        maxPurchaseLimit: _maxPurchaseLimits[i],
        minPurchaseLimit: _minPurchaseLimits[i],
        kyc: _kycs[i],
        weiRaised: 0
      }));
    }

    require(validPeriods());
  }

  function validPeriods() internal view returns (bool) {
    if (periods.length != MAX_PERIODS_COUNT) {
      return false;
    }

    // check periods are overlapped.
    for (uint8 i = 0; i < periods.length - 1; i++) {
      if (periods[i].endTime >= periods[i + 1].startTime) {
        return false;
      }
    }

    return true;
  }

  /**
   * @notice if period is on sale, return index of the period.
   */
  function getPeriodIndex() public view returns (uint8 currentPeriod, bool onSale) {
    onSale = true;
    Period memory p;

    for (currentPeriod = 0; currentPeriod < periods.length; currentPeriod++) {
      p = periods[currentPeriod];
      if (p.startTime <= now && now <= p.endTime) {
        return;
      }
    }

    onSale = false;
  }

  /**
   * @notice return if all period is finished.
   */
  function saleFinished() public view returns (bool) {
    require(periods.length == MAX_PERIODS_COUNT);
    return periods[periods.length - 1].endTime < now;
  }

  /**
   * @notice Override BaseCrowdsale.calculateToFund function.
   * Check if period is on sale and apply cap if needed.
   */
  function calculateToFund(address _beneficiary, uint256 _weiAmount) internal view returns (uint256) {
    uint8 currentPeriod;
    bool onSale;

    (currentPeriod, onSale) = getPeriodIndex();

    require(onSale);

    Period storage p = periods[currentPeriod];

    // Check kyc if needed for this period
    if (p.kyc) {
      require(super.registered(_beneficiary));
    }

    // pre-calculate `toFund` with the period's cap
    if (p.cap > 0) {
      uint256 postWeiRaised = p.weiRaised.add(_weiAmount);

      if (postWeiRaised > p.cap) {
        _weiAmount = p.cap.sub(weiRaised);
      }
    }

    // get `toFund` with the cap of the sale
    uint256 toFund = super.calculateToFund(_beneficiary, _weiAmount);

    p.weiRaised = p.weiRaised.add(toFund);

    return toFund;
  }
}
