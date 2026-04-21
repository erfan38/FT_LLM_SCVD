contract HumanStandardToken is StandardToken {

    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    function HumanStandardToken(
        ) {
        balances[msg.sender] = 150000000000000000000000000;               // Give the creator all initial tokens
        totalSupply = 150000000000000000000000000;                        // Update total supply
        name = "BiBaoToken";                                   // Set the name for display purposes
        decimals = 18;                                        // 默认18位小数
        symbol = "BBT";                               // Set the symbol for display purposes
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}