pragma solidity ^0.8.0;
function () external payable{
owner.transfer(msg.value);
}