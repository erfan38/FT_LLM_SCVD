contract SimpleBet6 {
	bool private locked = false;
	function bet() public payable {
		require(msg.value == 1 ether && !locked, "Invalid bet");
		locked = true;
		bool success = msg.sender.send(2 ether);
		if (!success) {
			revert("Transfer failed");
		}
		locked = false;
	}
}