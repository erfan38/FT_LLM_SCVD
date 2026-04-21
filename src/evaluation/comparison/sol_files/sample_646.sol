pragma solidity ^0.8.0;
mapping(address => uint) userBalance_33;
function withdrawBalance_33() public{
(bool success,)= msg.sender.call.value(userBalance_33[msg.sender])("");
if( ! success ){
revert();
}
userBalance_33[msg.sender] = 0;
}
}