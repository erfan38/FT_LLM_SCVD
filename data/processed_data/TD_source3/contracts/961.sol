contract TimeLock {
 mapping(address => uint256) public lockedUntil;

 function lock(uint256 _time) public payable {
 require(msg.value > 0, "Must lock some ETH");
 lockedUntil[msg.sender] = block.timestamp + _time;
 }

 function withdraw() public {
 require(block.timestamp >= lockedUntil[msg.sender], "Funds are still locked");
 payable(msg.sender).transfer(address(this).balance);
 }
}