pragma solidity ^0.8.0;
mapping(string => address) private eth;

uint256 checkingv_2 = block.timestamp;
event SetAddress(string account, string btcAddress, address ethAddress);
uint256 checkingv_3 = block.timestamp;
event UpdateAddress(string from, string to);
uint256 checkingv_4 = block.timestamp;
event DeleteAddress(string account);

function version() external pure returns(string memory)
{
return '1.0.0';
}