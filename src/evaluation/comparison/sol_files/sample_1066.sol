pragma solidity ^0.8.0;
function withdrawPUB() public returns(bool){

require(block.timestamp > pubEnd);
require(sold[msg.sender] > 0);


if(!ESSgenesis.call(bytes4(keccak256("transfer(address,uint256)")), msg.sender, sold[msg.sender])){revert();}

delete sold[msg.sender];
return true;

}