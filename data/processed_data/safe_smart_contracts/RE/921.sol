contract FinalizableCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;

    bool public isFinalized = false;

    event Finalized();

    function FinalizableCrowdsale(uint32 _startTime, uint32 _endTime, uint _rate, uint _hardCap, address _wallet, address _token)
            Crowdsale(_startTime, _endTime, _rate, _hardCap, _wallet, _token) {
    }

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() onlyOwner {
        require(!isFinalized);
        require(hasEnded());

        isFinalized = true;

        finalization();
        Finalized();        
    }

    /**
     * @dev Can be overriden to add finalization logic. The overriding function
     * should call super.finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function finalization() internal {
    }
}

/**
 * @title RefundableCrowdsale
 * @dev Extension of Crowdsale 