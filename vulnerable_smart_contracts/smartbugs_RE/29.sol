pragma solidity ^0.4.18;







contract BullTokenCrowdsale is CappedCrowdsale, RefundableCrowdsale {
  using SafeMath for uint256;

  Whitelist public whitelist;
  uint256 public minimumInvestment;

  function BullTokenCrowdsale(
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rate,
    uint256 _goal,
    uint256 _cap,
    uint256 _minimumInvestment,
    address _tokenAddress,
    address _wallet,
    address _whitelistAddress
  ) public
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    RefundableCrowdsale(_goal)
    BurnableCrowdsale(_startTime, _endTime, _rate, _wallet, _tokenAddress)
  {
    
    
    require(_goal <= _cap);

    whitelist = Whitelist(_whitelistAddress);
    minimumInvestment = _minimumInvestment;
  }

  function createTokenContract() internal returns (BurnableToken) {
    return BullToken(tokenAddress);
  }

  
  function () external payable {
    buyTokens(msg.sender);
  }

  
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(whitelist.isWhitelisted(beneficiary));

    uint256 weiAmount = msg.value;
    uint256 raisedIncludingThis = weiRaised.add(weiAmount);

    if (raisedIncludingThis > cap) {
      require(hasStarted() && !hasEnded());
      uint256 toBeRefunded = raisedIncludingThis.sub(cap);
      weiAmount = cap.sub(weiRaised);
      beneficiary.transfer(toBeRefunded);
    } else {
      require(validPurchase());
    }

    
    uint256 tokens = weiAmount.mul(rate);

    
    weiRaised = weiRaised.add(weiAmount);

    token.transferFrom(owner, beneficiary, tokens);

    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFundsToWallet(weiAmount);
  }

  
  
  function validPurchase() internal view returns (bool) {
    return super.validPurchase() && aboveMinimumInvestment();
  }

  
  
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised.add(minimumInvestment) > cap;
    return super.hasEnded() || capReached;
  }

  
  function hasStarted() public constant returns (bool) {
    return now >= startTime;
  }

  function aboveMinimumInvestment() internal view returns (bool) {
    return msg.value >= minimumInvestment;
  }

  function forwardFundsToWallet(uint256 amount) internal {
    if (goalReached() && vault.balance > 0) {
      vault.forwardFunds();
    }

    if (goalReached()) {
      wallet.call.value(amount)();
    } else {
      vault.deposit.value(amount)(msg.sender);
    }
  }

}