contract Pauseble is TokenERC20
{
    event EPause();
    event EUnpause();

    bool public paused = true;
    uint public startIcoDate = 0;

    modifier whenNotPaused()
    {
        require(!paused);
        _;
    }

    modifier whenPaused()
    {
        require(paused);
        _;
    }

    function pause() public onlyOwner
    {
        paused = true;
        emit EPause();
    }

    function pauseInternal() internal
    {
        paused = true;
        emit EPause();
    }

    function unpause() public onlyOwner
    {
        paused = false;
        emit EUnpause();
    }

    function unpauseInternal() internal
    {
        paused = false;
        emit EUnpause();
    }
}

