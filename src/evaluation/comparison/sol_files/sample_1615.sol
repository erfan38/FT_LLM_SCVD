pragma solidity ^0.8.0;
modifier onlyBeneficiary() {
require (msg.sender == beneficiary_);
_;
}

modifier onlyMatureEscrow() {
require (date_ < block.timestamp);
_;
}

}

contract Bittwatt is Token,Claimable, PausableToken {

string public constant name = "Bittwatt";
string public constant symbol = "BWT";
uint8 public constant decimals = 18;

address public _tokenAllocator;

function Bittwatt() public Token() {
pause();
}