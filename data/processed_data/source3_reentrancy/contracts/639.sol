contract BJAHCoin is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H1.0';

    function BJAHCoin () {
        balances[msg.sender] = 6969696969696969;
        totalSupply = 6969696969696969;
        name = "Blackjack and Hookers Coin";
        decimals = 9;
        symbol = "BJAH";
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 