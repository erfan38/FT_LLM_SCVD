contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        if (msg.sender != owner) {
            require(!paused);
        }
        _;
    }

    modifier whenPaused() {
        if (msg.sender != owner) {
            require(paused);
        }
        _;
    }

    function pause() onlyOwner public {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner public {
        paused = false;
        emit Unpause();
    }
}

library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        
        uint c = a / b;
        
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}

