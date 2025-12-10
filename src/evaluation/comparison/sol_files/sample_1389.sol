pragma solidity ^0.8.0;
contract TwoYearDreamTokensVesting {

using SafeMath for uint256;


ERC20TokenInterface public dreamToken;


address public withdrawalAddress = 0x0;


struct VestingStage {
uint256 date;
uint256 tokensUnlockedPercentage;
}


VestingStage[4] public stages;


uint256 public initialTokensBalance;


uint256 public tokensSent;


uint256 public vestingStartUnixTimestamp;


address public deployer;

modifier deployerOnly { require(msg.sender == deployer); _; }
modifier whenInitialized { require(withdrawalAddress != 0x0); _; }
modifier whenNotInitialized { require(withdrawalAddress == 0x0); _; }


event Withdraw(uint256 amount, uint256 timestamp);


constructor (ERC20TokenInterface token) public {
dreamToken = token;
deployer = msg.sender;
}


function () external {
withdrawTokens();
}