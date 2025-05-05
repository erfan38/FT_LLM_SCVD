contract EGAMEToken is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        revert();
    }

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H1.0';

    function EGAMEToken(
        ) {
        balances[msg.sender] = 120000000000000000;
        totalSupply = 120000000000000000;
        name = "EGAME Token";
        decimals = 8;
        symbol = "EGAMET";
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 