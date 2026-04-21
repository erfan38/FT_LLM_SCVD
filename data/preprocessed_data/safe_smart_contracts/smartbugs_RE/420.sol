contract SimpleBet4 {
	bool locked = false;
	function bet() external payable {
		require(msg.value == 1 ether && !locked, "Invalid bet");
		locked = true;
		(bool success, ) = msg.sender.call.value(2 ether)("");
		if (!success) {
			locked = false;
			revert("Transfer failed");
		}
	}
}