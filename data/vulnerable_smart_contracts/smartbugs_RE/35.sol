pragma solidity ^0.4.23;









interface IRegistry {
    function owner() external view returns (address _addr);
    function addressOf(bytes32 _name) external view returns (address _addr);
}

contract TaskManager is
    HasDailyLimit,
    Bankrollable,
    UsingAdmin,
    UsingMonarchyController
{
    uint constant public version = 1;
    uint public totalRewarded;

    
    
    uint public issueDividendRewardBips;
    
    
    uint public sendProfitsRewardBips;
    
    
    uint public monarchyStartReward;
    uint public monarchyEndReward;
    
    event Created(uint time);
    event DailyLimitChanged(uint time, address indexed owner, uint newValue);
    
    event IssueDividendRewardChanged(uint time, address indexed admin, uint newValue);
    event SendProfitsRewardChanged(uint time, address indexed admin, uint newValue);
    event MonarchyRewardsChanged(uint time, address indexed admin, uint startReward, uint endReward);
    
    event TaskError(uint time, address indexed caller, string msg);
    event RewardSuccess(uint time, address indexed caller, uint reward);
    event RewardFailure(uint time, address indexed caller, uint reward, string msg);
    
    event IssueDividendSuccess(uint time, address indexed treasury, uint profitsSent);
    event SendProfitsSuccess(uint time, address indexed bankrollable, uint profitsSent);
    event MonarchyGameStarted(uint time, address indexed addr, uint initialPrize);
    event MonarchyGamesRefreshed(uint time, uint numEnded, uint feesCollected);

    
    constructor(address _registry)
        public
        HasDailyLimit(1 ether)
        Bankrollable(_registry)
        UsingAdmin(_registry)
        UsingMonarchyController(_registry)
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


    
    
    

    function setIssueDividendReward(uint _bips)
        public
        fromAdmin
    {
        require(_bips <= 10);
        issueDividendRewardBips = _bips;
        emit IssueDividendRewardChanged(now, msg.sender, _bips);
    }

    function setSendProfitsReward(uint _bips)
        public
        fromAdmin
    {
        require(_bips <= 100);
        sendProfitsRewardBips = _bips;
        emit SendProfitsRewardChanged(now, msg.sender, _bips);
    }

    function setMonarchyRewards(uint _startReward, uint _endReward)
        public
        fromAdmin
    {
        require(_startReward <= 1 ether);
        require(_endReward <= 1 ether);
        monarchyStartReward = _startReward;
        monarchyEndReward = _endReward;
        emit MonarchyRewardsChanged(now, msg.sender, _startReward, _endReward);
    }


    
    
    

    function doIssueDividend()
        public
        returns (uint _reward, uint _profits)
    {
        
        ITreasury _tr = getTreasury();
        _profits = _tr.profitsSendable();
        
        if (_profits == 0) {
            _taskError("No profits to send.");
            return;
        }
        
        _profits = _tr.issueDividend();
        if (_profits == 0) {
            _taskError("No profits were sent.");
            return;
        } else {
            emit IssueDividendSuccess(now, address(_tr), _profits);
        }
        
        _reward = (_profits * issueDividendRewardBips) / 10000;
        _sendReward(_reward);
    }

    
    function issueDividendReward()
        public
        view
        returns (uint _reward, uint _profits)
    {
        _profits = getTreasury().profitsSendable();
        _reward = _cappedReward((_profits * issueDividendRewardBips) / 10000);
    }


    
    
    

    function doSendProfits(address _bankrollable)
        public
        returns (uint _reward, uint _profits)
    {
        
        ITreasury _tr = getTreasury();
        uint _oldTrBalance = address(_tr).balance;
        _IBankrollable(_bankrollable).sendProfits();
        uint _newTrBalance = address(_tr).balance;

        
        if (_newTrBalance <= _oldTrBalance) {
            _taskError("No profits were sent.");
            return;
        } else {
            _profits = _newTrBalance - _oldTrBalance;
            emit SendProfitsSuccess(now, _bankrollable, _profits);
        }
        
        
        _reward = (_profits * sendProfitsRewardBips) / 10000;
        _sendReward(_reward);
    }

    
    function sendProfitsReward(address _bankrollable)
        public
        view
        returns (uint _reward, uint _profits)
    {
        int _p = _IBankrollable(_bankrollable).profits();
        if (_p <= 0) return;
        _profits = uint(_p);
        _reward = _cappedReward((_profits * sendProfitsRewardBips) / 10000);
    }


    
    
    

    
    function startMonarchyGame(uint _index)
        public
    {
        
        IMonarchyController _mc = getMonarchyController();
        if (!_mc.getIsStartable(_index)){
            _taskError("Game is not currently startable.");
            return;
        }

        
        address _game = _mc.startDefinedGame(_index);
        if (_game == address(0)) {
            _taskError("MonarchyConroller.startDefinedGame() failed.");
            return;
        } else {
            emit MonarchyGameStarted(now, _game, _mc.getInitialPrize(_index));   
        }

        
        _sendReward(monarchyStartReward);
    }

    
    function startMonarchyGameReward()
        public
        view
        returns (uint _reward, uint _index)
    {
        IMonarchyController _mc = getMonarchyController();
        _index = _mc.getFirstStartableIndex();
        if (_index > 0) _reward = _cappedReward(monarchyStartReward);
    }


    
    function refreshMonarchyGames()
        public
    {
        
        uint _numGamesEnded;
        uint _feesCollected;
        (_numGamesEnded, _feesCollected) = getMonarchyController().refreshGames();
        emit MonarchyGamesRefreshed(now, _numGamesEnded, _feesCollected);

        if (_numGamesEnded == 0) {
            _taskError("No games ended.");
        } else {
            _sendReward(_numGamesEnded * monarchyEndReward);   
        }
    }
    
    
    function refreshMonarchyGamesReward()
        public
        view
        returns (uint _reward, uint _numEndable)
    {
        IMonarchyController _mc = getMonarchyController();
        _numEndable = _mc.getNumEndableGames();
        _reward = _cappedReward(_numEndable * monarchyEndReward);
    }


    
    
    

    
    function _taskError(string _msg) private {
        emit TaskError(now, msg.sender, _msg);
    }

    
    function _sendReward(uint _reward) private {
        
        uint _amount = _cappedReward(_reward);
        if (_reward > 0 && _amount == 0) {
            emit RewardFailure(now, msg.sender, _amount, "Not enough funds, or daily limit reached.");
            return;
        }

        
        if (msg.sender.call.value(_amount)()) {
            _useFromDailyLimit(_amount);
            totalRewarded += _amount;
            emit RewardSuccess(now, msg.sender, _amount);
        } else {
            emit RewardFailure(now, msg.sender, _amount, "Reward rejected by recipient (out of gas, or revert).");
        }
    }

    
    function _cappedReward(uint _reward) private view returns (uint) {
        uint _balance = address(this).balance;
        uint _remaining = getDailyLimitRemaining();
        if (_reward > _balance) _reward = _balance;
        if (_reward > _remaining) _reward = _remaining;
        return _reward;
    }

    
    function getCollateral() public view returns (uint) {}
    function getWhitelistOwner() public view returns (address){ return getAdmin(); }
}