contract VestingSchedule {
 uint256 public vestingStart;
 struct Beneficiary {
 uint256 _totalAmount;
 }
 mapping(address => Beneficiary) public beneficiaries;

 function calculateVestedAmount() internal view returns (uint256) {
 uint256 now = block.timestamp;
 uint256 vestingPeriod = now - vestingStart;
 uint256 vestedPercentage = vestingPeriod / (365 days) * 25;
 return beneficiaries[msg.sender]._totalAmount * vestedPercentage / 100;
 }
}