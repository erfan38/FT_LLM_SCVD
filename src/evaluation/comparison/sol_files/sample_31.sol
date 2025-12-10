pragma solidity ^0.8.0;
function registerImport(bytes8 originChain, bytes8 destChain, uint amount) public {
require(msg.sender == tokenPorter || msg.sender == owner);
require(validChain[originChain] && validChain[destChain]);

balance[originChain] = balance[originChain].sub(amount);
balance[destChain] = balance[destChain].add(amount);
emit LogRegisterImport(msg.sender, originChain, destChain, amount);
}