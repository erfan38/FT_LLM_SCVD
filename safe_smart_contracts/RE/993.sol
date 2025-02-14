contract MicroFinanceCoin is StandardToken {

    function () {
        throw;
    }
    string public name = 'MicroFinance Coin';                  
    uint8 public decimals = 18;                
    string public symbol = 'MFC';               
    string public version = 'V2.0';      

    function MicroFinanceCoin(
        ) {
        balances[msg.sender] = 20000000000000000000000000;
        totalSupply = 99999997000000000000000000;                      
        name = "MicroFinance Coin";                                   
        decimals = 18;                            
        symbol = "MFC";                              
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b; 
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}