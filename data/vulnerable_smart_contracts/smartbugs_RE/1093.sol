contract VulnerableDispatcher {
 mapping(address => uint) public balances;

 function dispatch(address[] memory recipients, uint[] memory amounts) public {
 for(uint i = 0; i < recipients.length; i++) {
 require(balances[msg.sender] >= amounts[i]);
 (bool success, ) = recipients[i].call{value: amounts[i]}("");
 require(success);
 balances[msg.sender] -= amounts[i];
 }
 }
}