contract SimpleBet5 {
	bool locked = false;
	uint public betAmount = 1 ether;
	function bet() public payable {
		require(msg.value == betAmount && !locked, "Invalid bet");
		if (!msg.sender.call.value(2 * betAmount)()) {
			locked = true;
			revert("Transfer failed");
		}
	}
}