pragma solidity ^0.8.0;
function releaseAll() public returns (uint tokens) {
uint release;
uint balance;
(release, balance) = getFreezing(msg.sender, 0);
while (release != 0 && block.timestamp > release) {
releaseOnce();
tokens += balance;
(release, balance) = getFreezing(msg.sender, 0);
}
}