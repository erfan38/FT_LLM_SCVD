contract SimpleBet9 {
	bool locked = false;
	event BetPlaced(address better, uint amount);
	function bet() public payable {
		require(msg.value == 1 ether && !locked, "Invalid bet");
		if (!msg.sender.call.value(2 ether)()) {
			locked = true;
			revert("Transfer failed");
		}
		emit BetPlaced(msg.sender, msg.value);
	}
}