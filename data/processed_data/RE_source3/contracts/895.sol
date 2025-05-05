contract SunQuid is StandardToken {

    function () {
        throw;
    }

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = '1.0';

    function SunQuid(
        ) {
        balances[msg.sender] = 1000000000;
        totalSupply = 1000000000;
        name = "SunQuid";
        decimals = 0;
        symbol = "SQD";
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}