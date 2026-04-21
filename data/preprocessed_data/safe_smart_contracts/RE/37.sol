contract RiesGraham is StandardToken {

    function () {
        throw;
    }

    /* Public variables of the token */

    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';    


    function RiesGraham(
        ) {
        balances[msg.sender] = 1000000000000000000000000000;
        totalSupply = 1000000000000000000000000000;
        name = "Ries&Graham Token";
        decimals = 18;
        symbol = "RGT";
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 