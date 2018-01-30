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
    uint startTime;
    uint endTime;
    uint cap;
    uint weiRaised;
    bool kyc;
  }

  function StagedCrowdsale(uint8 _MAX_PERIODS_COUNT) public {
    MAX_PERIODS_COUNT = _MAX_PERIODS_COUNT;
  }

  function initPeriods(uint[] _startTimes, uint[] _endTimes, uint[] _capRatios, bool[] _kycs) public {
    require(periods.length == 0); // one time init
    reqiure(_startTimes.length == _endTimes.length
      && _endTimes.length == _caps.length
      && _caps.length == _kycs.length);

    uint periodCap;

    for(uint i = 0; i < _startTimes.length; i++) {
      periodCap = coeff.add(_capRatios[i]).mul(cap).div(coeff);
      periods.push(Period(_startTimes[i], _endTimes[i], _caps[i], 0, _kycs[i]));
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
