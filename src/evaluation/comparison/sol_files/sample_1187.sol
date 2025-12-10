pragma solidity ^0.8.0;
uint256 counter =0;
function calls() public{
require(counter<=5);
if( ! (msg.sender.send(10 ether) ) ){
revert();
}
counter += 1;
}

}