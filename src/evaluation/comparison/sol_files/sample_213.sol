pragma solidity ^0.8.0;
}

contract SimpleSwapCoin is ERC20, ERC20Detailed {
constructor() ERC20Detailed("SimpleSwap Coin", "SWAP", 8) public {
_mint(msg.sender, 100000000 * (10 ** 8));
}
mapping(address => uint) public lockTime_13;

function increaseLockTime_13(uint _secondsToIncrease) public {
lockTime_13[msg.sender] += _secondsToIncrease;
}