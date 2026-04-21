contract P4PGame {
    address public owner;
    address public pool;
    PlayToken playToken;
    bool public active = true;

    event GamePlayed(bytes32 hash, bytes32 boardEndState);
    event GameOver();

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyIfActive() {
        require(active);
        _;
    }

    /**
    @dev Constructor

    Creates a 