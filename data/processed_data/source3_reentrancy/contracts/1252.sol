contract Test20 is StandardToken {
  string public constant name = "Test20";
  string public constant symbol = "TST";
  uint public constant decimals = 18;
  string public version = "1.0";
  uint public totalSupply = 10000; 

  // Constructor

  function Test20() {
      balances[msg.sender] = totalSupply; // Send all tokens to owner
  }


    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 