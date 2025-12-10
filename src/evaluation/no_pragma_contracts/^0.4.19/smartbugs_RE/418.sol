contract SimpleBet2 {
	bool locked = false;
	function bet() payable {
		require(msg.value == 1 ether && !locked);
		if (!msg.sender.call.value(2 ether)()) {
			locked = true;
			revert();
		}
	}
}