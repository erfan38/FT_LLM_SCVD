contract QRRial is StandardToken {

    function () {
        throw;
    }

    /* Public variables of the token */

    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';    


    function QRRial(
        ) {
        balances[msg.sender] = 21000000000000000000000000;
        totalSupply = 21000000000000000000000000;
        name = "QR Rial";
        decimals = 18;
        symbol = "QRR";
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 