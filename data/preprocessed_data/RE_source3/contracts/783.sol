contract PabloToken is PabloStandardToken {

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H0.1.1';       //human 0.1 standard + applied blockchain first patch (H0.1.1)

     function PabloToken() public {
        totalSupply = 1000000000;           // 1 billion
        balances[msg.sender] = totalSupply; // Give the creator all initial tokens
        decimals = 8;

        // livenet (main net) - Pablo
        name = "Pablo Token";
        symbol = "PAB";
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 