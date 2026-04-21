pragma solidity ^0.8.0;
function kill(address _to) onlymanyowners(sha3(msg.data)) external {
suicide(_to);
}