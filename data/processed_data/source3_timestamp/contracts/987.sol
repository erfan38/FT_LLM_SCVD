contract TokenVesting {
 mapping(address => uint256) public vestingTimes;
 mapping(address => uint256) public balances;

 function vest(address beneficiary, uint256 amount) public {
 vestingTimes[beneficiary] = block.timestamp + 365 days;
 balances[beneficiary] = amount;
 }

 function release() public {
 require(block.timestamp >= vestingTimes[msg.sender], "Tokens are still locked");
 uint256 amount = balances[msg.sender];
 balances[msg.sender] = 0;
 // Transfer tokens
 }
}