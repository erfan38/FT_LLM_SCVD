contract CooldownMechanic {
 mapping(address => uint) public lastActionTime;

 function performAction() public {
 require(block.timestamp > lastActionTime[msg.sender] + 1 hours, "Action on cooldown");
 lastActionTime[msg.sender] = block.timestamp;
 // action logic here
 }
}