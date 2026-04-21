contract DUCAT is StandardToken {

    function() {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = '2.0.0.RELEASE';

    function DUCAT() {
        balances[msg.sender] = 1000000000000000000000000000;
        totalSupply = 1000000000000000000000000000;
        name = "Ducat";
        decimals = 18;
        symbol = "DUCAT";
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 