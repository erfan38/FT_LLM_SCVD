contract Order is owned {
    ERC20 public token;
    uint public weiPerToken;
    uint public decimalPlaces;

    function Order(address _token, uint _weiPerToken, uint _decimalPlaces) {
        token = ERC20(_token);
        weiPerToken = _weiPerToken;
        decimalPlaces = _decimalPlaces;
    }

    function sendRobust(address to, uint value) internal {
        if (!to.send(value)) {
            if (!to.call.value(value)()) throw;
        }
    }

    function min(uint a, uint b) internal returns (uint) {
        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }

    function getTransferableBalance(address who) internal returns (uint amount) {
        uint allowance = token.allowance(msg.sender, address(this));
        uint balance = token.balanceOf(msg.sender);

        amount = min(min(allowance, balance), numTokensAbleToPurchase());

        return amount;
    }

    function numTokensAbleToPurchase() constant returns (uint) {
        return (this.balance / weiPerToken) * decimalPlaces;
    }

    event OrderFilled(address _from, uint numTokens);

    // Fills or partially fills the order.
    function _fillOrder(address _from, uint numTokens) internal returns (bool) {
        if (numTokens == 0) throw;
        if (this.balance < numTokens * weiPerToken / decimalPlaces) throw;

        if (!token.transferFrom(_from, owner, numTokens)) return false;
        sendRobust(_from, numTokens * weiPerToken / decimalPlaces);
        OrderFilled(_from, numTokens);
        return true;
    }

    function fillOrder(address _from, uint numTokens) public returns (bool) {
        return _fillOrder(_from, numTokens);
    }

    // Simpler call signature that uses `msg.sender`
    function fillMyOrder(uint numTokens) public returns (bool) {
        return _fillOrder(msg.sender, numTokens);
    }

    // Simpler call signature that defaults to the account allowance.
    function fillTheirOrder(address who) public returns (bool) {
        return _fillOrder(who, getTransferableBalance(who));
    }

    // Simpler call signature that uses `msg.sender` and the current approval
    // value.
    function fillOrderAuto() public returns (bool) {
        return _fillOrder(msg.sender, getTransferableBalance(msg.sender));
    }

    // Even simpler call signature that tries to transfer as many as possible.
    function () {
        // allow receipt of funds
        if (msg.value > 0) {
            return;
        } else {
            fillOrderAuto();
        }
    }

    // Cancel the order, returning all funds to the owner.
    function cancel() onlyowner {
        selfdestruct(owner);
    }
}