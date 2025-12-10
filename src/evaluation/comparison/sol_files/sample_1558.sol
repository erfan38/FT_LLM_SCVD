pragma solidity ^0.4.24;

contract ModifierEntrancy {
mapping (address => uint) public tokenBalance;
string constant name = "Nu Token";



function airDrop() hasNoBalance supportsToken  public{
tokenBalance[msg.sender] += 20;
}