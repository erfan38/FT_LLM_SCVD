contract iBurnableToken is iERC20Token {
  function burnTokens(uint _burnCount) public;
  function unPaidBurnTokens(uint _burnCount) public;
}

//import './SafeMath.sol';
pragma solidity ^0.4.11;

/*
    Overflow protected math functions
*/
