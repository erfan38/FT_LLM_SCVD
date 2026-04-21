contract PeriodicPayout {
 uint public lastPayoutTime;
 uint public constant PAYOUT_INTERVAL = 30 days;

 function claimPayout() public {
 require(block.timestamp >= lastPayoutTime + PAYOUT_INTERVAL, "Not time for payout yet");
 lastPayoutTime = block.timestamp;
 // payout logic here
 }
}