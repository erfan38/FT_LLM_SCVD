contract TimelockedWallet {
 uint public unlockTime;

 constructor(uint _unlockTime) {
 unlockTime = _unlockTime;
 }

 function withdraw() public {
 require(block.timestamp >= unlockTime, "Funds are still locked");
 // withdrawal logic here
 }
}