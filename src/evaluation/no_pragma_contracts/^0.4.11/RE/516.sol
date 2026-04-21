contract DatoxToken is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    string public constant name = "DATOX";
    string public constant symbol = "DTX";
    uint8 public constant decimals = 8;

    uint256 public constant INITIAL_SUPPLY = 200000000 * (10 ** uint256(decimals));

    function DatoxToken() {
        balances[msg.sender] = INITIAL_SUPPLY;               // Give the creator all initial tokens (100000 for example)
        totalSupply = INITIAL_SUPPLY;                        // Update total supply (100000 for example)
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 