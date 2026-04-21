contract TokenVesting {
 mapping(address => uint256) public vestedAmount;
 uint256 public vestingPeriod;

 constructor(uint256 _vestingPeriod) {
 vestingPeriod = _vestingPeriod;
 }

 function vest(address _beneficiary, uint256 _amount) public {
 vestedAmount[_beneficiary] += _amount;
 }

 function release() public {
 require(block.timestamp >= vestingPeriod, "Vesting period not over");
 uint256 amount = vestedAmount[msg.sender];
 require(amount > 0, "No tokens to release");
 vestedAmount[msg.sender] = 0;
 (bool success, ) = msg.sender.call{value: amount}("");
 require(success, "Transfer failed");
 }
}