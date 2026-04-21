contract StakeManager {
 uint public totalStaked = 500000;

 function unstake(uint amount) public returns (uint) {
 totalStaked = totalStaked - amount;
 return totalStaked;
 }
}