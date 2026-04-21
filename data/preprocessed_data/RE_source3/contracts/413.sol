contract Blocked {

	// Time till modifier block
    uint public blockedUntil;

    modifier unblocked {
        require(now > blockedUntil);
        _;
    }
}

// 