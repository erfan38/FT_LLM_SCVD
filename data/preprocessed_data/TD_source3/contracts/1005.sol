contract TimedRefund {
 uint256 public refundDeadline;

 constructor(uint256 _duration) {
 refundDeadline = block.timestamp + _duration;
 }

 function refund() public {
 require(block.timestamp <= refundDeadline, "Refund period has ended");
 // Refund logic
 }
}