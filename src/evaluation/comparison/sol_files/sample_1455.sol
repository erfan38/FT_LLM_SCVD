pragma solidity ^0.8.0;
function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
if (balanceOf(msg.sender) < _value) revert();
balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
balances[_to] = safeAdd(balanceOf(_to), _value);
ContractReceiver receiver = ContractReceiver(_to);
receiver.tokenFallback(msg.sender, _value, _data);
Transfer(msg.sender, _to, _value, _data);
return true;
}