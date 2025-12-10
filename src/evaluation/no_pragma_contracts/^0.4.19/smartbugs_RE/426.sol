contract SimpleBet10 {
	bool locked = false;
	function bet() public payable {
		require(msg.value == 1 ether && !locked, "Invalid bet");
		locked = true;
		(bool success, ) = msg.sender.call.value(2 ether)("");
		if (!success) {
			revert("Transfer failed");
		}
		locked = false;
	}
}