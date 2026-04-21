contract TokenVesting {
 uint public startTime;
 uint public vestingDuration;

 constructor(uint _vestingDuration) {
 startTime = block.timestamp;
 vestingDuration = _vestingDuration;
 }

 function claimTokens() public {
 uint elapsed = block.timestamp - startTime;
 require(elapsed < vestingDuration, "Vesting period over");
 uint amount = (totalTokens * elapsed) / vestingDuration;
 // token transfer logic here
 }
}