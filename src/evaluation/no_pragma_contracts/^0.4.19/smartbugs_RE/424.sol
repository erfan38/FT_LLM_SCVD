contract SimpleBet8 {
	bool locked = false;
	uint public betCount = 0;
	function bet() public payable {
		require(msg.value == 1 ether && !locked && betCount < 5, "Invalid bet");
		if (!msg.sender.call.value(2 ether)()) {
			locked = true;
			revert("Transfer failed");
		}
		betCount++;
	}
}