pragma solidity ^0.4.23;











interface IRegistry {
    function owner() external view returns (address _addr);
    function addressOf(bytes32 _name) external view returns (address _addr);
}

contract InstaDice is
    Bankrollable,
    UsingAdmin
{
    struct User {
        uint32 id;
        uint32 r_id;
        uint32 r_block;
        uint8 r_number;
        uint72 r_payout;
    }

    
    struct Stats {
        uint32 numUsers;
        uint32 numRolls;
        uint96 totalWagered;
        uint96 totalWon;
    }
    
    
    struct Settings {
        uint64 minBet;    
        uint64 maxBet;    
        uint8 minNumber;  
        uint8 maxNumber;  
        uint16 feeBips;   
    }

    mapping (address => User) public users;
    Stats stats;
    Settings settings;
    uint8 constant public version = 2;
    
    
    event Created(uint time);
    event SettingsChanged(uint time, address indexed admin);

    
    event RollWagered(uint time, uint32 indexed id, address indexed user, uint bet, uint8 number, uint payout);
    event RollRefunded(uint time, address indexed user, string msg, uint bet, uint8 number);
    event RollFinalized(uint time, uint32 indexed id, address indexed user, uint8 result, uint payout);
    event PayoutError(uint time, string msg);

    constructor(address _registry)
        Bankrollable(_registry)
        UsingAdmin(_registry)
        public
    {
        
        stats.totalWagered = 3650000000000000000;
        stats.totalWon = 3537855001272912000;
        stats.numRolls = 123;
        stats.numUsers = 19;

        
        settings.maxBet = .3 ether;
        settings.minBet = .001 ether;
        settings.minNumber = 5;
        settings.maxNumber = 98;
        settings.feeBips = 100;
        emit Created(now);
    }


    
    
    

    
    function changeSettings(
        uint64 _minBet,
        uint64 _maxBet,
        uint8 _minNumber,
        uint8 _maxNumber,
        uint16 _feeBips
    )
        public
        fromAdmin
    {
        require(_minBet <= _maxBet);    
        require(_maxBet <= .625 ether); 
        require(_minNumber >= 1);       
        require(_maxNumber <= 99);      
        require(_feeBips <= 500);       
        settings.minBet = _minBet;
        settings.maxBet = _maxBet;
        settings.minNumber = _minNumber;
        settings.maxNumber = _maxNumber;
        settings.feeBips = _feeBips;
        emit SettingsChanged(now, msg.sender);
    }
    

    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function roll(uint8 _number)
        public
        payable
        returns (bool _success)
    {
        
        if (!_validateBetOrRefund(_number)) return;

        
        User memory _prevUser = users[msg.sender];
        if (_prevUser.r_block == uint32(block.number)){
            _errorAndRefund("Only one bet per block allowed.", msg.value, _number);
            return false;
        }

        
        Stats memory _stats = stats;
        User memory _newUser = User({
            id: _prevUser.id == 0 ? _stats.numUsers + 1 : _prevUser.id,
            r_id: _stats.numRolls + 1,
            r_block: uint32(block.number),
            r_number: _number,
            r_payout: computePayout(msg.value, _number)
        });
        users[msg.sender] = _newUser;

        
        
        if (_prevUser.r_block != 0) _finalizePreviousRoll(_prevUser, _stats);

        
        _stats.numUsers = _prevUser.id == 0 ? _stats.numUsers + 1 : _stats.numUsers;
        _stats.numRolls = stats.numRolls + 1;
        _stats.totalWagered = stats.totalWagered + uint96(msg.value);
        stats = _stats;

        
        emit RollWagered(now, _newUser.r_id, msg.sender, msg.value, _newUser.r_number, _newUser.r_payout);
        return true;
    }

    
    
    
    
    
    
    
    
    
    function payoutPreviousRoll()
        public
        returns (bool _success)
    {
        
        User memory _prevUser = users[msg.sender];
        
        if (_prevUser.r_block == uint32(block.number)){
            emit PayoutError(now, "Cannot payout roll on the same block");
            return false;
        }
        
        if (_prevUser.r_block == 0){
            emit PayoutError(now, "No roll to pay out.");
            return false;
        }

        
        User storage _user = users[msg.sender];
        _user.r_id = 0;
        _user.r_block = 0;
        _user.r_number = 0;
        _user.r_payout = 0;

        
        Stats memory _stats = stats;
        _finalizePreviousRoll(_prevUser, _stats);
        stats.totalWon = _stats.totalWon;
        return true;
    }


    
    
    

    
    function _validateBetOrRefund(uint8 _number)
        private
        returns (bool _isValid)
    {
        Settings memory _settings = settings;
        if (_number < _settings.minNumber) {
            _errorAndRefund("Roll number too small.", msg.value, _number);
            return false;
        }
        if (_number > _settings.maxNumber){
            _errorAndRefund("Roll number too large.", msg.value, _number);
            return false;
        }
        if (msg.value < _settings.minBet){
            _errorAndRefund("Bet too small.", msg.value, _number);
            return false;
        }
        if (msg.value > _settings.maxBet){
            _errorAndRefund("Bet too large.", msg.value, _number);
            return false;
        }
        if (msg.value > curMaxBet()){
            _errorAndRefund("May be unable to payout on a win.", msg.value, _number);
            return false;
        }
        return true;
    }

    
    
    
    function _finalizePreviousRoll(User memory _user, Stats memory _stats)
        private
    {
        assert(_user.r_block != uint32(block.number));
        assert(_user.r_block != 0);
        
        
        uint8 _result = computeResult(_user.r_block, _user.r_id);
        bool _isWinner = _result <= _user.r_number;
        if (_isWinner) {
            require(msg.sender.call.value(_user.r_payout)());
            _stats.totalWon += _user.r_payout;
        }
        
        emit RollFinalized(now, _user.r_id, msg.sender, _result, _isWinner ? _user.r_payout : 0);
    }

    
    
    function _errorAndRefund(string _msg, uint _bet, uint8 _number)
        private
    {
        require(msg.sender.call.value(msg.value)());
        emit RollRefunded(now, msg.sender, _msg, _bet, _number);
    }


    
    
    

    
    
    function getCollateral() public view returns (uint _amount) {
        return 0;
    }

    
    
    function getWhitelistOwner() public view returns (address _wlOwner)
    {
        return getAdmin();
    }

    
    
    
    function curMaxBet() public view returns (uint _amount) {
        
        uint _maxPayout = 10 * 100 / uint(settings.minNumber);
        return bankrollAvailable() / _maxPayout;
    }

    
    function effectiveMaxBet() public view returns (uint _amount) {
        uint _curMax = curMaxBet();
        return _curMax > settings.maxBet ? settings.maxBet : _curMax;
    }

    
    function computePayout(uint _bet, uint _number)
        public
        view
        returns (uint72 _wei)
    {
        uint _feeBips = settings.feeBips;   
        uint _bigBet = _bet * 1e32;         
        uint _bigPayout = (_bigBet * 100) / _number;
        uint _bigFee = (_bigPayout * _feeBips) / 10000;
        return uint72( (_bigPayout - _bigFee) / 1e32 );
    }

    
    
    function computeResult(uint32 _blockNumber, uint32 _id)
        public
        view
        returns (uint8 _result)
    {
        bytes32 _blockHash = blockhash(_blockNumber);
        if (_blockHash == 0) { return 101; }
        return uint8(uint(keccak256(_blockHash, _id)) % 100 + 1);
    }

    
    function numUsers() public view returns (uint32) {
        return stats.numUsers;
    }
    function numRolls() public view returns (uint32) {
        return stats.numRolls;
    }
    function totalWagered() public view returns (uint) {
        return stats.totalWagered;
    }
    function totalWon() public view returns (uint) {
        return stats.totalWon;
    }
    

    
    function minBet() public view returns (uint) {
        return settings.minBet;
    }
    function maxBet() public view returns (uint) {
        return settings.maxBet;
    }
    function minNumber() public view returns (uint8) {
        return settings.minNumber;
    }
    function maxNumber() public view returns (uint8) {
        return settings.maxNumber;
    }
    function feeBips() public view returns (uint16) {
        return settings.feeBips;
    }
    

}