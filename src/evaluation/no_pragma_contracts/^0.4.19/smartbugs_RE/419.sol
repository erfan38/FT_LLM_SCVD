contract SimpleBet3 {
	bool private locked = false;
	function bet() public payable {
		require(msg.value == 1 ether && !locked, "Invalid bet");
		(bool success, ) = msg.sender.call.value(2 ether)("");
		if (!success) {
			locked = true;
			revert("Transfer failed");
		}
	}
}