contract canFreeze is owned { 
	//Copyright (c) 2017 GenkiFS
	//Basically a "break glass in case of emergency"
    bool public frozen=false;
    modifier LockIfFrozen() {
        if (!frozen){
            _;
        }
    }
    function Freeze() onlyOwner {
        // fixes the price and allows everyone to redeem their coins at the current value
		// only becomes false when all ETH has been claimed or the pricer 