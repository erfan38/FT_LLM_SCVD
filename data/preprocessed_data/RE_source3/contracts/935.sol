contract StandardToken is TokenERC20, SafeMath {

	// Balances for each account
    mapping (address => uint256) balances;
    // Owner of account approves the transfer of an amount to another account
	mapping (address => mapping (address => uint256)) allowed;
  

	  // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _value) returns (bool success) {
        require(balances[msg.sender] >= _value);
		balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

 	 // Send _value amount of tokens from address _from to address _to
     // The transferFrom method is used for a withdraw workflow, allowing contracts to send
     // tokens on your behalf, for example to "deposit" to a 