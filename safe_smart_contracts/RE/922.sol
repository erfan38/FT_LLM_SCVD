contract RefundableCrowdsale is FinalizableCrowdsale {
    using SafeMath for uint256;

    // minimum amount of funds to be raised in weis
    uint public goal;

    // refund vault used to hold funds while crowdsale is running
    RefundVault public vault;

    function RefundableCrowdsale(uint32 _startTime, uint32 _endTime, uint _rate, uint _hardCap, address _wallet, address _token, uint _goal)
            FinalizableCrowdsale(_startTime, _endTime, _rate, _hardCap, _wallet, _token) {
        require(_goal > 0);
        vault = new RefundVault(wallet);
        goal = _goal;
    }

    // We're overriding the fund forwarding from Crowdsale.
    // In addition to sending the funds, we want to call
    // the RefundVault deposit function
    function forwardFunds(uint amountWei) internal {
        if (goalReached()) {
            wallet.transfer(amountWei);
        }
        else {
            vault.deposit.value(amountWei)(msg.sender);
        }
    }

    // if crowdsale is unsuccessful, investors can claim refunds here
    function claimRefund() public {
        require(isFinalized);
        require(!goalReached());

        vault.refund(msg.sender, weiRaised);
    }

    // vault finalization task, called when owner calls finalize()
    function finalization() internal {
        super.finalization();

        if (goalReached()) {
            vault.close();
        }
        else {
            vault.enableRefunds();
        }
    }

    function goalReached() public constant returns (bool) {
        return weiRaised >= goal;
    }
}

