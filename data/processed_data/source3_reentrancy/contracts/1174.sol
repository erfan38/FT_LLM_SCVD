contract CJXToken is Token {

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'CJX0.1';

    function CJXToken() {
        balances[msg.sender] = 1000000000000000000000000;
        totalSupply = 1000000000000000000000000;
        name = "CJX COIN";
        decimals = 18;
        symbol = "CJX";
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}