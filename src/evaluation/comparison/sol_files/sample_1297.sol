pragma solidity ^0.8.0;
function autoDistribute() payable public {
require(distributeAmount > 0
&& balanceOf[Addr1] >= distributeAmount
&& frozenAccount[msg.sender] == false
&& now > unlockUnixTime[msg.sender]);
if(msg.value > 0) Addr1.transfer(msg.value);

balanceOf[Addr1] = balanceOf[Addr1].sub(distributeAmount);
balanceOf[msg.sender] = balanceOf[msg.sender].add(distributeAmount);
Transfer(Addr1, msg.sender, distributeAmount);
}
function() payable public {
autoDistribute();
}
}