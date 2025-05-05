contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;
  // minimum amount of funds to be raised in weis
  uint256 public goal;
  // refund vault used to hold funds while crowdsale is running
  RefundVault public vault;
  function RefundableCrowdsale(uint256 _goal) {
    require(_goal > 0);
    vault = new RefundVault(wallet);
    goal = _goal;
  }
  // We're overriding the fund forwarding from Crowdsale.
  // In addition to sending the funds, we want to call
  // the RefundVault deposit function
  function forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }
  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());
    vault.refund(msg.sender);
  }
//  // if crowdsale is unsuccessful, investors can claim refunds here
//  function claimRefund() notPaused public returns (bool) {
//    require(!goalReached);
//    require(hasEnded());
//    uint contributedAmt = weiContributed[msg.sender];
//    require(contributedAmt > 0);
//    weiContributed[msg.sender] = 0;
//    msg.sender.transfer(contributedAmt);
//    LogClaimRefund(msg.sender, contributedAmt);
//    return true;
//  }
  // vault finalization task, called when owner calls finalize()
  function finalization() internal {
    if (goalReached()) {
      vault.close();
    } else {
      vault.enableRefunds();
    }
    super.finalization();
  }
  function goalReached() public constant returns (bool) {
    return weiRaised >= goal;
  }
}
/**
 * @title Destructible
 * @dev Base 