contract TokenExchange {
 mapping(address => uint) public balances;

 function exchangeTokens(uint _amount) public {
 require(balances[msg.sender] >= _amount);
 balances[msg.sender] -= _amount;
 (bool success, ) = msg.sender.call(abi.encodeWithSignature("receiveTokens(uint256)", _amount));
 require(success);
 }
}