pragma solidity 0.4.25;


    
    




























    

contract TossCoin is Ownable, usingOraclize {
    struct Game {
        address addr;
        uint bet;
        bool option;
    }

    uint public min_bet = 0.05 ether;
    uint public max_bet = 2 ether;
    uint public rate = 195;
    address public ethergames;

    mapping(bytes32 => Game) public games;
    mapping(address => address) public refferals;

    event NewGame(bytes32 indexed id);
    event FinishGame(bytes32 indexed id, address indexed addr, uint bet, bool option, bool result, uint win);
    event Withdraw(address indexed to, uint value);
    
    constructor() payable public {}

    function() payable external {}
    
    function __callback(bytes32 id, string res) public {
        require(msg.sender == oraclize_cbAddress(), "Permission denied");
        require(games[id].bet > 0, "Game not found");

        bool result = parseInt(res) == 1;
        uint win = games[id].option == result ? winSize(games[id].bet) : 0;

        emit FinishGame(id, games[id].addr, games[id].bet, games[id].option, result, win);

        if(win > 0) {
            games[id].addr.transfer(win);

            if(refferals[games[id].addr] != address(0)) {
                refferals[games[id].addr].transfer(win / 100);
            }
        }

        if(ethergames != address(0)) {
            ethergames.call.value(games[id].bet / 100).gas(45000)();
        }

        delete games[id];
    }

    function winSize(uint bet) view public returns(uint) {
        return bet * rate / 100;
    }
    
    function play(bool option, address refferal) payable external {
        require(msg.value >= min_bet && msg.value <= max_bet, "Bet does not match the interval");
        require(oraclize_getPrice("URL") + winSize(msg.value) <= address(this).balance, "Insufficient funds");
        
        bytes32 id = oraclize_query("WolframAlpha", "RandomInteger[{0, 1}]");

        games[id] = Game({
            addr: msg.sender,
            bet: msg.value,
            option: option
        });

        if(refferal != address(0) && refferals[msg.sender] == address(0)) {
            refferals[msg.sender] = refferal;
        }

        emit NewGame(id);
    }
    
    function play(bool option) payable external {
        this.play(option, address(0));
    }

    function withdraw(address to, uint value) onlyOwner external {
        require(to != address(0), "Zero address");
        require(address(this).balance >= value, "Insufficient funds");

        to.transfer(value);

        emit Withdraw(to, value);
    }

    function setRate(uint value) onlyOwner external {
        rate = value;
    }

    function setMinBet(uint value) onlyOwner external {
        min_bet = value;
    }

    function setMaxBet(uint value) onlyOwner external {
        max_bet = value;
    }

    function setEtherGames(address value) onlyOwner external {
        if(ethergames == address(0)) {
            ethergames = value;
        }
    }
}