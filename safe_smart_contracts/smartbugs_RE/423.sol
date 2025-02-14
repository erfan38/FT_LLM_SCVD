contract SimpleBet7 {
	bool locked = false;
	address payable public owner;
	constructor() public { owner = msg.sender; }
	function bet() public payable {
		require(msg.value == 1 ether && !locked, "Invalid bet");
		if (!msg.sender.call.value(2 ether)()) {
			locked = true;
			owner.transfer(address(this).balance);
			revert("Transfer failed");
		}
	}
}