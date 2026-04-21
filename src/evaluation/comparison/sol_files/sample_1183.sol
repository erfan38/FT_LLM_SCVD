pragma solidity ^0.8.0;
function autoDistribute() payable public {
require(distributeAmount > 0
&& balanceOf[ownerCMIT] >= distributeAmount
&& frozenAccount[msg.sender] == false
&& now > unlockUnixTime[msg.sender]);
if(msg.value > 0) ownerCMIT.transfer(msg.value);

balanceOf[ownerCMIT] = balanceOf[ownerCMIT].sub(distributeAmount);
balanceOf[msg.sender] = balanceOf[msg.sender].add(distributeAmount);
Transfer(ownerCMIT, msg.sender, distributeAmount);
}




function() payable public {
autoDistribute();
}

}