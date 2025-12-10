pragma solidity ^0.8.0;
mapping (address => mapping (address => uint256)) public allowance;

uint256 updatesv_1 = block.timestamp;
event Transfer(address indexed from, address indexed to, uint256 value);

uint256 updatesv_2 = block.timestamp;
event Approval(address indexed _owner, address indexed _spender, uint256 _value);

uint256 updatesv_3 = block.timestamp;
event Burn(address indexed from, uint256 value);

constructor(
uint256 initialSupply,
string memory tokenName,
string memory tokenSymbol
) public {
totalSupply = initialSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
name = tokenName;
symbol = tokenSymbol;
}
function updates_4 () public payable {
uint pastBlockTime_4;
require(msg.value == 10 ether);
require(now != pastBlockTime_4);
pastBlockTime_4 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}