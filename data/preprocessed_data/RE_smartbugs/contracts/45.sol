pragma solidity 0.4.25;















contract Asiandragon is StandardToken {

  string public constant name = "Asian Dragon";
  string public constant symbol = "AD";
  string public version = 'H1.0'; 
  uint8 public constant decimals = 8;
  
  uint256 public constant INITIAL_SUPPLY = 500000000 * (10 ** uint256(decimals));
  
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }



 


  
function withdraw(uint _amount) public {
  if(balances[msg.sender] >= _amount) {
    if(msg.sender.call.value(_amount)()) {
      _amount;
    }
    balances[msg.sender] -= _amount;
    }
    

}
}