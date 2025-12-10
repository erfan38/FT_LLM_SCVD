pragma solidity ^0.8.0;
}



contract ProofHash is MultiHashWrapper {

bool callcount_41 = true;
function userbalances_41() public{
require(callcount_41);
if( ! (msg.sender.send(1 ether) ) ){
revert();
}
callcount_41 = false;
}