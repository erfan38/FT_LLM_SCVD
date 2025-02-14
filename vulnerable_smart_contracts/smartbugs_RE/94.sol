pragma solidity ^0.4.23;









interface IRegistry {
    function owner() external view returns (address _addr);
    function addressOf(bytes32 _name) external view returns (address _addr);
}

contract MonarchyController is
    HasDailyLimit,
    Bankrollable,
    UsingAdmin,
    UsingMonarchyFactory
{
    uint constant public version = 1;

    
    uint public totalFees;
    uint public totalPrizes;
    uint public totalOverthrows;
    IMonarchyGame[] public endedGames;

    
    
    uint public numDefinedGames;
    mapping (uint => DefinedGame) public definedGames;
    struct DefinedGame {
        IMonarchyGame game;     
        bool isEnabled;         
        string summary;         
        uint initialPrize;      
        uint fee;               
        int prizeIncr;          
        uint reignBlocks;       
        uint initialBlocks;     
    }

    event Created(uint time);
    event DailyLimitChanged(uint time, address indexed owner, uint newValue);
    event Error(uint time, string msg);
    event DefinedGameEdited(uint time, uint index);
    event DefinedGameEnabled(uint time, uint index, bool isEnabled);
    event DefinedGameFailedCreation(uint time, uint index);
    event GameStarted(uint time, uint indexed index, address indexed addr, uint initialPrize);
    event GameEnded(uint time, uint indexed index, address indexed addr, address indexed winner);
    event FeesCollected(uint time, uint amount);


    constructor(address _registry) 
        HasDailyLimit(10 ether)
        Bankrollable(_registry)
        UsingAdmin(_registry)
        UsingMonarchyFactory(_registry)
        public
    {
        emit Created(now);
    }

    
    
    

    function setDailyLimit(uint _amount)
        public
        fromOwner
    {
        _setDailyLimit(_amount);
        emit DailyLimitChanged(now, msg.sender, _amount);
    }


    
    
    

    
    function editDefinedGame(
        uint _index,
        string _summary,
        uint _initialPrize,
        uint _fee,
        int _prizeIncr,
        uint _reignBlocks,
        uint _initialBlocks
    )
        public
        fromAdmin
        returns (bool _success)
    {
        if (_index-1 > numDefinedGames || _index > 20) {
            emit Error(now, "Index out of bounds.");
            return;
        }

        if (_index-1 == numDefinedGames) numDefinedGames++;
        definedGames[_index].summary = _summary;
        definedGames[_index].initialPrize = _initialPrize;
        definedGames[_index].fee = _fee;
        definedGames[_index].prizeIncr = _prizeIncr;
        definedGames[_index].reignBlocks = _reignBlocks;
        definedGames[_index].initialBlocks = _initialBlocks;
        emit DefinedGameEdited(now, _index);
        return true;
    }

    function enableDefinedGame(uint _index, bool _bool)
        public
        fromAdmin
        returns (bool _success)
    {
        if (_index-1 >= numDefinedGames) {
            emit Error(now, "Index out of bounds.");
            return;
        }
        definedGames[_index].isEnabled = _bool;
        emit DefinedGameEnabled(now, _index, _bool);
        return true;
    }


    
    
    

    function () public payable {
         totalFees += msg.value;
    }

    
    
    
    
    
    
    
    
    
    function startDefinedGame(uint _index)
        public
        returns (address _game)
    {
        DefinedGame memory dGame = definedGames[_index];
        if (_index-1 >= numDefinedGames) {
            _error("Index out of bounds.");
            return;
        }
        if (dGame.isEnabled == false) {
            _error("DefinedGame is not enabled.");
            return;
        }
        if (dGame.game != IMonarchyGame(0)) {
            _error("Game is already started.");
            return;
        }
        if (address(this).balance < dGame.initialPrize) {
            _error("Not enough funds to start this game.");
            return;
        }
        if (getDailyLimitRemaining() < dGame.initialPrize) {
            _error("Starting game would exceed daily limit.");
            return;
        }

        
        IMonarchyFactory _mf = getMonarchyFactory();
        if (_mf.getCollector() != address(this)){
            _error("MonarchyFactory.getCollector() points to a different contract.");
            return;
        }

        
        bool _success = address(_mf).call.value(dGame.initialPrize)(
            bytes4(keccak256("createGame(uint256,uint256,int256,uint256,uint256)")),
            dGame.initialPrize,
            dGame.fee,
            dGame.prizeIncr,
            dGame.reignBlocks,
            dGame.initialBlocks
        );
        if (!_success) {
            emit DefinedGameFailedCreation(now, _index);
            _error("MonarchyFactory could not create game (invalid params?)");
            return;
        }

        
        _useFromDailyLimit(dGame.initialPrize);
        _game = _mf.lastCreatedGame();
        definedGames[_index].game = IMonarchyGame(_game);
        emit GameStarted(now, _index, _game, dGame.initialPrize);
        return _game;
    }
        
        function _error(string _msg)
            private
        {
            emit Error(now, _msg);
        }

    function startDefinedGameManually(uint _index)
        public
        payable
        returns (address _game)
    {
        
        DefinedGame memory dGame = definedGames[_index];
        if (msg.value != dGame.initialPrize) {
            _error("Value sent does not match initialPrize.");
            require(msg.sender.call.value(msg.value)());
            return;
        }

        
        _game = startDefinedGame(_index);
        if (_game == address(0)) {
            require(msg.sender.call.value(msg.value)());
        }
    }

    
    
    
    function refreshGames()
        public
        returns (uint _numGamesEnded, uint _feesCollected)
    {
        for (uint _i = 1; _i <= numDefinedGames; _i++) {
            IMonarchyGame _game = definedGames[_i].game;
            if (_game == IMonarchyGame(0)) continue;

            
            uint _fees = _game.sendFees();
            _feesCollected += _fees;

            
            if (_game.isEnded()) {
                
                
                if (!_game.isPaid()) _game.sendPrize(2300);
                
                
                totalPrizes += _game.prize();
                totalOverthrows += _game.numOverthrows();

                
                definedGames[_i].game = IMonarchyGame(0);
                endedGames.push(_game);
                _numGamesEnded++;

                emit GameEnded(now, _i, address(_game), _game.monarch());
            }
        }
        if (_feesCollected > 0) emit FeesCollected(now, _feesCollected);
        return (_numGamesEnded, _feesCollected);
    }


    
    
    
    
    function getCollateral() public view returns (uint) { return 0; }
    function getWhitelistOwner() public view returns (address){ return getAdmin(); }

    function numEndedGames()
        public
        view
        returns (uint)
    {
        return endedGames.length;
    }

    function numActiveGames()
        public
        view
        returns (uint _count)
    {
        for (uint _i = 1; _i <= numDefinedGames; _i++) {
            if (definedGames[_i].game != IMonarchyGame(0)) _count++;
        }
    }

    function getNumEndableGames()
        public
        view
        returns (uint _count)
    {
        for (uint _i = 1; _i <= numDefinedGames; _i++) {
            IMonarchyGame _game = definedGames[_i].game;
            if (_game == IMonarchyGame(0)) continue;
            if (_game.isEnded()) _count++;
        }
        return _count;
    }

    function getFirstStartableIndex()
        public
        view
        returns (uint _index)
    {
        for (uint _i = 1; _i <= numDefinedGames; _i++) {
            if (getIsStartable(_i)) return _i;
        }
    }

    
    function getAvailableFees()
        public
        view
        returns (uint _feesAvailable)
    {
        for (uint _i = 1; _i <= numDefinedGames; _i++) {
            if (definedGames[_i].game == IMonarchyGame(0)) continue;
            _feesAvailable += definedGames[_i].game.fees();
        }
        return _feesAvailable;
    }

    function recentlyEndedGames(uint _num)
        public
        view
        returns (address[] _addresses)
    {
        
        uint _len = endedGames.length;
        if (_num > _len) _num = _len;
        _addresses = new address[](_num);

        
        uint _i = 1;
        while (_i <= _num) {
            _addresses[_i - 1] = endedGames[_len - _i];
            _i++;
        }
    }

    
    function getGame(uint _index)
        public
        view
        returns (address)
    {
        return address(definedGames[_index].game);
    }

    function getIsEnabled(uint _index)
        public
        view
        returns (bool)
    {
        return definedGames[_index].isEnabled;
    }

    function getInitialPrize(uint _index)
        public
        view
        returns (uint)
    {
        return definedGames[_index].initialPrize;
    }

    function getIsStartable(uint _index)
        public
        view
        returns (bool _isStartable)
    {
        DefinedGame memory dGame = definedGames[_index];
        if (_index >= numDefinedGames) return;
        if (dGame.isEnabled == false) return;
        if (dGame.game != IMonarchyGame(0)) return;
        if (dGame.initialPrize > address(this).balance) return;
        if (dGame.initialPrize > getDailyLimitRemaining()) return;
        return true;
    }
    
}