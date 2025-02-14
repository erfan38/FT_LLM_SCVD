pragma solidity ^0.4.23;











interface IRegistry {
    function owner() external view returns (address _addr);
    function addressOf(bytes32 _name) external view returns (address _addr);
}

contract VideoPoker is
    VideoPokerUtils,
    Bankrollable,
    UsingAdmin
{
    
    struct Game {
        
        uint32 userId;
        uint64 bet;         
        uint16 payTableId;  
        uint32 iBlock;      
        uint32 iHand;       
        uint8 draws;        
        uint32 dBlock;      
        uint32 dHand;       
        uint8 handRank;     
    }

    
    
    
    struct Vars {
        
        uint32 curId;               
        uint64 totalWageredGwei;    
        uint32 curUserId;           
        uint128 empty1;             
                                    
        
        uint64 totalWonGwei;        
        uint88 totalCredits;        
        uint8 empty2;               
    }

    struct Settings {
        uint64 minBet;
        uint64 maxBet;
        uint16 curPayTableId;
        uint16 numPayTables;
        uint32 lastDayAdded;
    }

    Settings settings;
    Vars vars;

    
    mapping(uint32 => Game) public games;
    
    
    mapping(address => uint) public credits;

    
    
    
    
    mapping (address => uint32) public userIds;
    mapping (uint32 => address) public userAddresses;

    
    
    mapping(uint16=>uint16[12]) payTables;

    
    uint8 public constant version = 2;
    uint8 constant WARN_IHAND_TIMEOUT = 1; 
    uint8 constant WARN_DHAND_TIMEOUT = 2; 
    uint8 constant WARN_BOTH_TIMEOUT = 3;  
    
    
    event Created(uint time);
    event PayTableAdded(uint time, address admin, uint payTableId);
    event SettingsChanged(uint time, address admin);
    
    event BetSuccess(uint time, address indexed user, uint32 indexed id, uint bet, uint payTableId);
    event BetFailure(uint time, address indexed user, uint bet, string msg);
    event DrawSuccess(uint time, address indexed user, uint32 indexed id, uint32 iHand, uint8 draws, uint8 warnCode);
    event DrawFailure(uint time, address indexed user, uint32 indexed id, uint8 draws, string msg);
    event FinalizeSuccess(uint time, address indexed user, uint32 indexed id, uint32 dHand, uint8 handRank, uint payout, uint8 warnCode);
    event FinalizeFailure(uint time, address indexed user, uint32 indexed id, string msg);
    
    event CreditsAdded(uint time, address indexed user, uint32 indexed id, uint amount);
    event CreditsUsed(uint time, address indexed user, uint32 indexed id, uint amount);
    event CreditsCashedout(uint time, address indexed user, uint amount);
        
    constructor(address _registry)
        Bankrollable(_registry)
        UsingAdmin(_registry)
        public
    {
        
        _addPayTable(800, 50, 25, 9, 6, 4, 3, 2, 1);
        
        
        
        
        vars.curId = 293;
        vars.totalWageredGwei =2864600000;
        vars.curUserId = 38;
        vars.totalWonGwei = 2450400000;

        
        settings.minBet = .001 ether;
        settings.maxBet = .375 ether;
        emit Created(now);
    }
    
    
    
    
    
    
    
    function changeSettings(uint64 _minBet, uint64 _maxBet, uint8 _payTableId)
        public
        fromAdmin
    {
        require(_maxBet <= .375 ether);
        require(_payTableId < settings.numPayTables);
        settings.minBet = _minBet;
        settings.maxBet = _maxBet;
        settings.curPayTableId = _payTableId;
        emit SettingsChanged(now, msg.sender);
    }
    
    
    function addPayTable(
        uint16 _rf, uint16 _sf, uint16 _fk, uint16 _fh,
        uint16 _fl, uint16 _st, uint16 _tk, uint16 _tp, uint16 _jb
    )
        public
        fromAdmin
    {
        uint32 _today = uint32(block.timestamp / 1 days);
        require(settings.lastDayAdded < _today);
        settings.lastDayAdded = _today;
        _addPayTable(_rf, _sf, _fk, _fh, _fl, _st, _tk, _tp, _jb);
        emit PayTableAdded(now, msg.sender, settings.numPayTables-1);
    }
    

    
    
    

    
    function addCredits()
        public
        payable
    {
        _creditUser(msg.sender, msg.value, 0);
    }

    
    function cashOut(uint _amt)
        public
    {
        _uncreditUser(msg.sender, _amt);
    }

    
    
    
    
    
    
    
    
    function bet()
        public
        payable
    {
        uint _bet = msg.value;
        if (_bet > settings.maxBet)
            return _betFailure("Bet too large.", _bet, true);
        if (_bet < settings.minBet)
            return _betFailure("Bet too small.", _bet, true);
        if (_bet > curMaxBet())
            return _betFailure("The bankroll is too low.", _bet, true);

        
        uint32 _id = _createNewGame(uint64(_bet));
        emit BetSuccess(now, msg.sender, _id, _bet, settings.curPayTableId);
    }

    
    
    
    
    
    
    
    
    
    
    function betWithCredits(uint64 _bet)
        public
    {
        if (_bet > settings.maxBet)
            return _betFailure("Bet too large.", _bet, false);
        if (_bet < settings.minBet)
            return _betFailure("Bet too small.", _bet, false);
        if (_bet > curMaxBet())
            return _betFailure("The bankroll is too low.", _bet, false);
        if (_bet > credits[msg.sender])
            return _betFailure("Insufficient credits", _bet, false);

        uint32 _id = _createNewGame(uint64(_bet));
        vars.totalCredits -= uint88(_bet);
        credits[msg.sender] -= _bet;
        emit CreditsUsed(now, msg.sender, _id, _bet);
        emit BetSuccess(now, msg.sender, _id, _bet, settings.curPayTableId);
    }

    function betFromGame(uint32 _id, bytes32 _hashCheck)
        public
    {
        bool _didFinalize = finalize(_id, _hashCheck);
        uint64 _bet = games[_id].bet;
        if (!_didFinalize)
            return _betFailure("Failed to finalize prior game.", _bet, false);
        betWithCredits(_bet);
    }

        
        function _betFailure(string _msg, uint _bet, bool _doRefund)
            private
        {
            if (_doRefund) require(msg.sender.call.value(_bet)());
            emit BetFailure(now, msg.sender, _bet, _msg);
        }
        

    
    
    
    
    
    
    
    
    
    
    
    function draw(uint32 _id, uint8 _draws, bytes32 _hashCheck)
        public
    {
        Game storage _game = games[_id];
        address _user = userAddresses[_game.userId];
        if (_game.iBlock == 0)
            return _drawFailure(_id, _draws, "Invalid game Id.");
        if (_user != msg.sender)
            return _drawFailure(_id, _draws, "This is not your game.");
        if (_game.iBlock == block.number)
            return _drawFailure(_id, _draws, "Initial cards not available.");
        if (_game.dBlock != 0)
            return _drawFailure(_id, _draws, "Cards already drawn.");
        if (_draws > 31)
            return _drawFailure(_id, _draws, "Invalid draws.");
        if (_draws == 0)
            return _drawFailure(_id, _draws, "Cannot draw 0 cards. Use finalize instead.");
        if (_game.handRank != HAND_UNDEFINED)
            return _drawFailure(_id, _draws, "Game already finalized.");
        
        _draw(_game, _id, _draws, _hashCheck);
    }
        function _drawFailure(uint32 _id, uint8 _draws, string _msg)
            private
        {
            emit DrawFailure(now, msg.sender, _id, _draws, _msg);
        }
      

    
    
    
    
    
    
    
    function finalize(uint32 _id, bytes32 _hashCheck)
        public
        returns (bool _didFinalize)
    {
        Game storage _game = games[_id];
        address _user = userAddresses[_game.userId];
        if (_game.iBlock == 0)
            return _finalizeFailure(_id, "Invalid game Id.");
        if (_user != msg.sender)
            return _finalizeFailure(_id, "This is not your game.");
        if (_game.iBlock == block.number)
            return _finalizeFailure(_id, "Initial hand not avaiable.");
        if (_game.dBlock == block.number)
            return _finalizeFailure(_id, "Drawn cards not available.");
        if (_game.handRank != HAND_UNDEFINED)
            return _finalizeFailure(_id, "Game already finalized.");

        _finalize(_game, _id, _hashCheck);
        return true;
    }
        function _finalizeFailure(uint32 _id, string _msg)
            private
            returns (bool)
        {
            emit FinalizeFailure(now, msg.sender, _id, _msg);
            return false;
        }


    
    
    

    
    
    function _addPayTable(
        uint16 _rf, uint16 _sf, uint16 _fk, uint16 _fh,
        uint16 _fl, uint16 _st, uint16 _tk, uint16 _tp, uint16 _jb
    )
        private
    {
        require(_rf<=1600 && _sf<=100 && _fk<=50 && _fh<=18 && _fl<=12 
                 && _st<=8 && _tk<=6 && _tp<=4 && _jb<=2);

        uint16[12] memory _pt;
        _pt[HAND_UNDEFINED] = 0;
        _pt[HAND_RF] = _rf;
        _pt[HAND_SF] = _sf;
        _pt[HAND_FK] = _fk;
        _pt[HAND_FH] = _fh;
        _pt[HAND_FL] = _fl;
        _pt[HAND_ST] = _st;
        _pt[HAND_TK] = _tk;
        _pt[HAND_TP] = _tp;
        _pt[HAND_JB] = _jb;
        _pt[HAND_HC] = 0;
        _pt[HAND_NOT_COMPUTABLE] = 0;
        payTables[settings.numPayTables] = _pt;
        settings.numPayTables++;
    }

    
    
    function _creditUser(address _user, uint _amt, uint32 _gameId)
        private
    {
        if (_amt == 0) return;
        uint64 _incr = _gameId == 0 ? 0 : uint64(_amt / 1e9);
        uint88 _totalCredits = vars.totalCredits + uint88(_amt);
        uint64 _totalWonGwei = vars.totalWonGwei + _incr;
        vars.totalCredits = _totalCredits;
        vars.totalWonGwei = _totalWonGwei;
        credits[_user] += _amt;
        emit CreditsAdded(now, _user, _gameId, _amt);
    }

    
    
    function _uncreditUser(address _user, uint _amt)
        private
    {
        if (_amt > credits[_user] || _amt == 0) _amt = credits[_user];
        if (_amt == 0) return;
        vars.totalCredits -= uint88(_amt);
        credits[_user] -= _amt;
        require(_user.call.value(_amt)());
        emit CreditsCashedout(now, _user, _amt);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    function _createNewGame(uint64 _bet)
        private
        returns (uint32 _curId)
    {
        
        uint32 _curUserId = vars.curUserId;
        uint32 _userId = userIds[msg.sender];
        if (_userId == 0) {
            _curUserId++;
            userIds[msg.sender] = _curUserId;
            userAddresses[_curUserId] = msg.sender;
            _userId = _curUserId;
        }

        
        _curId =  vars.curId + 1;
        uint64 _totalWagered = vars.totalWageredGwei + _bet / 1e9;
        vars.curId = _curId;
        vars.totalWageredGwei = _totalWagered;
        vars.curUserId = _curUserId;

        
        uint16 _payTableId = settings.curPayTableId;
        Game storage _game = games[_curId];
        _game.userId = _userId;
        _game.bet = _bet;
        _game.payTableId = _payTableId;
        _game.iBlock = uint32(block.number);
        return _curId;
    }

    
    
    
    
    
    
    function _draw(Game storage _game, uint32 _id, uint8 _draws, bytes32 _hashCheck)
        private
    {
        
        assert(_game.dBlock == 0);

        
        uint32 _iHand;
        bytes32 _iBlockHash = blockhash(_game.iBlock);
        uint8 _warnCode;
        if (_iBlockHash != 0) {
            
            if (_iBlockHash != _hashCheck) {
                return _drawFailure(_id, _draws, "HashCheck Failed. Try refreshing game.");
            }
            _iHand = getHand(uint(keccak256(_iBlockHash, _id)));
        } else {
            _warnCode = WARN_IHAND_TIMEOUT;
            _draws = 31;
        }

        
        _game.iHand = _iHand;
        _game.draws = _draws;
        _game.dBlock = uint32(block.number);

        emit DrawSuccess(now, msg.sender, _id, _game.iHand, _draws, _warnCode);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function _finalize(Game storage _game, uint32 _id, bytes32 _hashCheck)
        private
    {
        
        assert(_game.handRank == HAND_UNDEFINED);

        
        address _user = userAddresses[_game.userId];
        bytes32 _blockhash;
        uint32 _dHand;
        uint32 _iHand;  
        uint8 _warnCode;
        if (_game.draws != 0) {
            _blockhash = blockhash(_game.dBlock);
            if (_blockhash != 0) {
                
                _dHand = drawToHand(uint(keccak256(_blockhash, _id)), _game.iHand, _game.draws);
            } else {
                
                if (_game.iHand != 0){
                    _dHand = _game.iHand;
                    _warnCode = WARN_DHAND_TIMEOUT;
                } else {
                    _dHand = 0;
                    _warnCode = WARN_BOTH_TIMEOUT;
                }
            }
        } else {
            _blockhash = blockhash(_game.iBlock);
            if (_blockhash != 0) {
                
                if (_blockhash != _hashCheck) {
                    _finalizeFailure(_id, "HashCheck Failed. Try refreshing game.");
                    return;
                }
                
                _iHand = getHand(uint(keccak256(_blockhash, _id)));
                _dHand = _iHand;
            } else {
                
                _finalizeFailure(_id, "Initial hand not available. Drawing 5 new cards.");
                _game.draws = 31;
                _game.dBlock = uint32(block.number);
                emit DrawSuccess(now, _user, _id, 0, 31, WARN_IHAND_TIMEOUT);
                return;
            }
        }

        
        uint8 _handRank = _dHand == 0
            ? uint8(HAND_NOT_COMPUTABLE)
            : uint8(getHandRank(_dHand));

        
        if (_iHand > 0) _game.iHand = _iHand;
        
        _game.dHand = _dHand;
        _game.handRank = _handRank;

        
        uint _payout = payTables[_game.payTableId][_handRank] * uint(_game.bet);
        if (_payout > 0) _creditUser(_user, _payout, _id);
        emit FinalizeSuccess(now, _user, _id, _game.dHand, _game.handRank, _payout, _warnCode);
    }



    
    
    

    
    
    function getCollateral() public view returns (uint _amount) {
        return vars.totalCredits;
    }

    
    
    function getWhitelistOwner() public view returns (address _wlOwner) {
        return getAdmin();
    }

    
    
    
    function curMaxBet() public view returns (uint) {
        
        uint _maxPayout = payTables[settings.curPayTableId][HAND_RF] * 2;
        return bankrollAvailable() / _maxPayout;
    }

    
    function effectiveMaxBet() public view returns (uint _amount) {
        uint _curMax = curMaxBet();
        return _curMax > settings.maxBet ? settings.maxBet : _curMax;
    }

    function getPayTable(uint16 _payTableId)
        public
        view
        returns (uint16[12])
    {
        require(_payTableId < settings.numPayTables);
        return payTables[_payTableId];
    }

    function getCurPayTable()
        public
        view
        returns (uint16[12])
    {
        return getPayTable(settings.curPayTableId);
    }

    
    function getIHand(uint32 _id)
        public
        view
        returns (uint32)
    {
        Game memory _game = games[_id];
        if (_game.iHand != 0) return _game.iHand;
        if (_game.iBlock == 0) return;
        
        bytes32 _iBlockHash = blockhash(_game.iBlock);
        if (_iBlockHash == 0) return;
        return getHand(uint(keccak256(_iBlockHash, _id)));
    }

    
    
    function getDHand(uint32 _id)
        public
        view
        returns (uint32)
    {
        Game memory _game = games[_id];
        if (_game.dHand != 0) return _game.dHand;
        if (_game.draws == 0) return _game.iHand;
        if (_game.dBlock == 0) return;

        bytes32 _dBlockHash = blockhash(_game.dBlock);
        if (_dBlockHash == 0) return _game.iHand;
        return drawToHand(uint(keccak256(_dBlockHash, _id)), _game.iHand, _game.draws);
    }

    
    function getDHandRank(uint32 _id)
        public
        view
        returns (uint8)
    {
        uint32 _dHand = getDHand(_id);
        return _dHand == 0
            ? uint8(HAND_NOT_COMPUTABLE)
            : uint8(getHandRank(_dHand));
    }

    
    function curId() public view returns (uint32) {
        return vars.curId;
    }
    function totalWagered() public view returns (uint) {
        return uint(vars.totalWageredGwei) * 1e9;
    }
    function curUserId() public view returns (uint) {
        return uint(vars.curUserId);
    }
    function totalWon() public view returns (uint) {
        return uint(vars.totalWonGwei) * 1e9;
    }
    function totalCredits() public view returns (uint) {
        return vars.totalCredits;
    }
    

    
    function minBet() public view returns (uint) {
        return settings.minBet;
    }
    function maxBet() public view returns (uint) {
        return settings.maxBet;
    }
    function curPayTableId() public view returns (uint) {
        return settings.curPayTableId;
    }
    function numPayTables() public view returns (uint) {
        return settings.numPayTables;
    }
    
}