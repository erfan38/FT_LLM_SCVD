contract DSStop is DSNote, DSAuth {
    bool public stopped;

    modifier stoppable {
        require(!stopped);
        _;
    }
    function stop() public auth note {
        stopped = true;
    }

    function start() public auth note {
        stopped = false;
    }
}

