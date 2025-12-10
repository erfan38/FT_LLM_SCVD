






















contract OwnedAccount is ErrorHandler {
    address public owner;
    bool acceptDeposits = true;

    event evPayOut(address msg_sender, uint msg_value, address indexed _recipient, uint _amount);

    modifier onlyOwner() {
        if (msg.sender != owner) doThrow("onlyOwner");
        else {_}
    }

    modifier noEther() {
        if (msg.value > 0) doThrow("noEther");
        else {_}
    }

    function OwnedAccount(address _owner) {
        owner = _owner;
    }

    function payOutPercentage(address _recipient, uint _percent) internal onlyOwner noEther {
        payOutAmount(_recipient, (this.balance * _percent) / 100);
    }

    function payOutAmount(address _recipient, uint _amount) internal onlyOwner noEther {
        
        if (!_recipient.call.value(_amount)())
            doThrow("payOut:sendFailed");
        else
            evPayOut(msg.sender, msg.value, _recipient, _amount);
    }

    function () returns (bool success) {
        if (!acceptDeposits) throw;
        return true;
    }
}
