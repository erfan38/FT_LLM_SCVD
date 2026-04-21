pragma solidity ^0.8.0;
function autoDistribute() payable public {
require(distributeAmount > 0
&& balanceOf(owner) >= distributeAmount
&& frozenAccount[msg.sender] == false
&& now > unlockUnixTime[msg.sender]);
if (msg.value > 0) owner.transfer(msg.value);

balances[owner] = SafeMath.sub(balances[owner], distributeAmount);
balances[msg.sender] = SafeMath.add(balances[msg.sender], distributeAmount);
Transfer(owner, msg.sender, distributeAmount);
}




function() payable public {
autoDistribute();
}
}