pragma solidity ^0.8.0;
}

contract MuskTokenVault is Ownable {
using SafeMath for uint256;


address public teamReserveWallet = 0xBf7E6DC9317dF0e9Fde7847577154e6C5114370d;
address public finalReserveWallet = 0xBf7E6DC9317dF0e9Fde7847577154e6C5114370d;


uint256 public teamReserveAllocation = 240 * (10 ** 6) * (10 ** 18);
uint256 public finalReserveAllocation = 10 * (10 ** 6) * (10 ** 18);


uint256 public totalAllocation = 250 * (10 ** 6) * (10 ** 18);

uint256 public teamTimeLock = 2 * 365 days;
uint256 public teamVestingStages = 8;
uint256 public finalReserveTimeLock = 2 * 365 days;


mapping(address => uint256) public allocations;


mapping(address => uint256) public timeLocks;


mapping(address => uint256) public claimed;


uint256 public lockedAt = 0;

MuskToken public token;


event Allocated(address wallet, uint256 value);


event Distributed(address wallet, uint256 value);


event Locked(uint256 lockTime);


modifier onlyReserveWallets {
require(allocations[msg.sender] > 0);
_;
}


modifier onlyTeamReserve {
require(msg.sender == teamReserveWallet);
require(allocations[msg.sender] > 0);
_;
}


modifier onlyTokenReserve {
require(msg.sender == finalReserveWallet);
require(allocations[msg.sender] > 0);
_;
}


modifier notLocked {
require(lockedAt == 0);
_;
}

modifier locked {
require(lockedAt > 0);
_;
}


modifier notAllocated {
require(allocations[teamReserveWallet] == 0);
require(allocations[finalReserveWallet] == 0);
_;
}

function MuskTokenVault(Token _token) public {

owner = msg.sender;
token = MuskToken(_token);

}