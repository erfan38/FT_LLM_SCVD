pragma solidity ^0.8.0;
}

contract Authorization {
mapping(address => address) public agentBooks;
address public owner;
address public operator;
address public bank;
bool public powerStatus = true;
bool public forceOff = false;
function Authorization()
public
{
owner = msg.sender;
operator = msg.sender;
bank = msg.sender;
}