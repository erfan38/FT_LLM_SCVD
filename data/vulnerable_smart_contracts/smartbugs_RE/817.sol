pragma solidity ^0.4.24;








contract WarOfTokens is Pausable {
    using SafeMath for uint256;

    struct AttackInfo {
        address attacker;
        address attackee;
        uint attackerScore;
        uint attackeeScore;
        bytes32 attackId;
        bool completed;
        uint hodlSpellBlockNumber;
        mapping (address => uint256) attackerWinnings;
        mapping (address => uint256) attackeeWinnings;
    }

    
    event Deposit(address token, address user, uint amount, uint balance);
    event Withdraw(address token, address user, uint amount, uint balance);
    event UserActiveStatusChanged(address user, bool isActive);
    event Attack (
        address indexed attacker,
        address indexed attackee,
        bytes32 attackId,
        uint attackPrizePercent,
        uint base,
        uint hodlSpellBlockNumber
    );
    event AttackCompleted (
        bytes32 indexed attackId,
        address indexed winner,
        uint attackeeActualScore
    );

    
    


    mapping (address => mapping (address => uint256)) public tokens;
    mapping (address => bool) public activeUsers;
    address public cdtTokenAddress;
    uint256 public minCDTToParticipate;
    MarketDataStorage public marketDataOracle;
    uint public maxAttackPrizePercent; 
    uint attackPricePrecentBase = 1000; 
    uint public maxOpenAttacks = 5;
    mapping (bytes32 => AttackInfo) public attackIdToInfo;
    mapping (address => mapping(address => bytes32)) public userToUserToAttackId;
    mapping (address => uint) public cntUserAttacks; 


    
    modifier activeUserOnly(address user) {
        require(
            isActiveUser(user),
            "User not active"
        );
        _;
    }

    constructor(address _cdtTokenAddress,
        uint256 _minCDTToParticipate,
        address _marketDataOracleAddress,
        uint _maxAttackPrizeRatio)
    Pausable()
    public {
        cdtTokenAddress = _cdtTokenAddress;
        minCDTToParticipate = _minCDTToParticipate;
        marketDataOracle = MarketDataStorage(_marketDataOracleAddress);
        setMaxAttackPrizePercent(_maxAttackPrizeRatio);
    }

    
    function() public {
        revert("Please do not send ETH without calling the deposit function. We will not do it automatically to validate your intent");
    }

    
    function isActiveUser(address user) view public returns (bool) {
        return activeUsers[user];
    }

    
    
    
    
    

    
    


    function deposit() payable external whenNotPaused {
        tokens[0][msg.sender] = tokens[0][msg.sender].add(msg.value);
        emit Deposit(0, msg.sender, msg.value, tokens[0][msg.sender]);

        _validateUserActive(msg.sender);
    }

    


    function depositToken(address token, uint amount) external whenNotPaused {
        
        require(
            token!=0,
            "unrecognized token"
        );
        assert(StandardToken(token).transferFrom(msg.sender, this, amount));
        tokens[token][msg.sender] =  tokens[token][msg.sender].add(amount);
        emit Deposit(token, msg.sender, amount, tokens[token][msg.sender]);

        _validateUserActive(msg.sender);
    }

    function withdraw(uint amount) external {
        tokens[0][msg.sender] = tokens[0][msg.sender].sub(amount);
        assert(msg.sender.call.value(amount)());
        emit Withdraw(0, msg.sender, amount, tokens[0][msg.sender]);

        _validateUserActive(msg.sender);
    }

    function withdrawToken(address token, uint amount) external {
        require(
            token!=0,
            "unrecognized token"
        );
        tokens[token][msg.sender] = tokens[token][msg.sender].sub(amount);
        assert(StandardToken(token).transfer(msg.sender, amount));
        emit Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);

        _validateUserActive(msg.sender);
    }

    function balanceOf(address token, address user) view public returns (uint) {
        return tokens[token][user];
    }

    
    
    
    
    
    function setMaxAttackPrizePercent(uint newAttackPrize) onlyOwner public {
        require(
            newAttackPrize < 5,
            "max prize is 5 percent of funds"
        );
        maxAttackPrizePercent = newAttackPrize;
    }

    function setMaxOpenAttacks(uint newValue) onlyOwner public {
        maxOpenAttacks = newValue;
    }

    function openAttacksCount(address user) view public returns (uint) {
        return cntUserAttacks[user];
    }

    function isTokenSupported(address token_address) view public returns (bool) {
        return marketDataOracle.isTokenSupported(token_address);
    }

    function getUserScore(address user)
    view
    public
    whenNotPaused
    returns (uint) {
        uint cnt_supported_tokens = marketDataOracle.numberOfSupportedTokens();
        uint aggregated_score = 0;
        for (uint i=0; i<cnt_supported_tokens; i++) {
            (address token_address, uint volume, uint depth, uint marketcap) = marketDataOracle.getMarketDataByTokenIdx(i);
            uint256 user_balance = balanceOf(token_address, user);

            aggregated_score = aggregated_score + _calculateScore(user_balance, volume, depth, marketcap);
        }

        return aggregated_score;
    }

    function _calculateScore(uint256 balance, uint volume, uint depth, uint marketcap) pure internal returns (uint) {
        return balance * volume * depth * marketcap;
    }

    function attack(address attackee)
    external
    activeUserOnly(msg.sender)
    activeUserOnly(attackee)
    {
        require(
            msg.sender != attackee,
            "Can't attack yourself"
        );
        require(
            userToUserToAttackId[msg.sender][attackee] == 0,
            "Cannot attack while pending attack exists, please complete attack"
        );
        require(
            openAttacksCount(msg.sender) < maxOpenAttacks,
            "Too many open attacks for attacker"
        );
        require(
            openAttacksCount(attackee) < maxOpenAttacks,
            "Too many open attacks for attackee"
        );

        (uint attackPrizePercent, uint attackerScore, uint attackeeScore) = attackPrizeRatio(attackee);

        AttackInfo memory attackInfo = AttackInfo(
            msg.sender,
            attackee,
            attackerScore,
            attackeeScore,
            sha256(abi.encodePacked(msg.sender, attackee, block.blockhash(block.number-1))), 
            false,
            block.number 
        );
        _registerAttack(attackInfo);

        _calculateWinnings(attackIdToInfo[attackInfo.attackId], attackPrizePercent);

        emit Attack(
            attackInfo.attacker,
            attackInfo.attackee,
            attackInfo.attackId,
            attackPrizePercent,
            attackPricePrecentBase,
            attackInfo.hodlSpellBlockNumber
        );
    }

    




    function attackPrizeRatio(address attackee)
    view
    public
    returns (uint attackPrizePercent, uint attackerScore, uint attackeeScore) {
        uint _attackerScore = getUserScore(msg.sender);
        require(
            _attackerScore > 0,
            "attacker score is 0"
        );
        uint _attackeeScore = getUserScore(attackee);
        require(
            _attackeeScore > 0,
            "attackee score is 0"
        );

        uint howCloseAreThey = _attackeeScore.mul(attackPricePrecentBase).div(_attackerScore);

        return (howCloseAreThey, _attackerScore, _attackeeScore);
    }

    function attackerPrizeByToken(bytes32 attackId, address token_address) view public returns (uint256) {
        return attackIdToInfo[attackId].attackerWinnings[token_address];
    }

    function attackeePrizeByToken(bytes32 attackId, address token_address) view public returns (uint256) {
        return attackIdToInfo[attackId].attackeeWinnings[token_address];
    }

    
    function completeAttack(bytes32 attackId) public {
        AttackInfo storage attackInfo = attackIdToInfo[attackId];

        (address winner, uint attackeeActualScore) = getWinner(attackId);

        
        uint cnt_supported_tokens = marketDataOracle.numberOfSupportedTokens();
        for (uint i=0; i<cnt_supported_tokens; i++) {
            (address token_address, bool status) = marketDataOracle.getSupportedTokenByIndex(i);

            if (attackInfo.attacker == winner) {
                uint winnings = attackInfo.attackerWinnings[token_address];

                if (winnings > 0) {
                    tokens[token_address][attackInfo.attackee] = tokens[token_address][attackInfo.attackee].sub(winnings);
                    tokens[token_address][attackInfo.attacker] = tokens[token_address][attackInfo.attacker].add(winnings);
                }
            }
            else {
                uint loosings = attackInfo.attackeeWinnings[token_address];

                if (loosings > 0) {
                    tokens[token_address][attackInfo.attacker] = tokens[token_address][attackInfo.attacker].sub(loosings);
                    tokens[token_address][attackInfo.attackee] = tokens[token_address][attackInfo.attackee].add(loosings);
                }
            }
        }

        
        _unregisterAttack(attackId);

        emit AttackCompleted(
            attackId,
            winner,
            attackeeActualScore
        );
    }

    function getWinner(bytes32 attackId) public view returns(address winner, uint attackeeActualScore) {
        require(
            block.number >= attackInfo.hodlSpellBlockNumber,
            "attack can not be completed at this block, please wait"
        );

        AttackInfo storage attackInfo = attackIdToInfo[attackId];

        
        
        
        
        if (block.number - attackInfo.hodlSpellBlockNumber >= 256) {
            return (attackInfo.attackee, attackInfo.attackeeScore);
        }

        bytes32 blockHash = block.blockhash(attackInfo.hodlSpellBlockNumber);
        return _calculateWinnerBasedOnEntropy(attackInfo, blockHash);
    }

    
    
    
    
    

    
    function _validateUserActive(address user) private {
        
        uint256 cdt_balance = balanceOf(cdtTokenAddress, user);

        bool new_active_state = cdt_balance >= minCDTToParticipate;
        bool current_active_state = activeUsers[user]; 

        if (current_active_state != new_active_state) { 
            emit UserActiveStatusChanged(user, new_active_state);
        }

        activeUsers[user] = new_active_state;
    }

    function _registerAttack(AttackInfo attackInfo) internal {
        userToUserToAttackId[attackInfo.attacker][attackInfo.attackee] = attackInfo.attackId;
        userToUserToAttackId[attackInfo.attackee][attackInfo.attacker] = attackInfo.attackId;

        attackIdToInfo[attackInfo.attackId] = attackInfo;

        
        cntUserAttacks[attackInfo.attacker] = cntUserAttacks[attackInfo.attacker].add(1);
        cntUserAttacks[attackInfo.attackee] = cntUserAttacks[attackInfo.attackee].add(1);
    }

    function _unregisterAttack(bytes32 attackId) internal {
        AttackInfo storage attackInfo = attackIdToInfo[attackId];

        cntUserAttacks[attackInfo.attacker] = cntUserAttacks[attackInfo.attacker].sub(1);
        cntUserAttacks[attackInfo.attackee] = cntUserAttacks[attackInfo.attackee].sub(1);

        delete userToUserToAttackId[attackInfo.attacker][attackInfo.attackee];
        delete userToUserToAttackId[attackInfo.attackee][attackInfo.attacker];

        delete attackIdToInfo[attackId];
    }

    



    function _calculateWinnings(AttackInfo storage attackInfo, uint attackPrizePercent) internal {
        
        uint cnt_supported_tokens = marketDataOracle.numberOfSupportedTokens();

        uint actualPrizeRation = attackPrizePercent
        .mul(maxAttackPrizePercent);


        for (uint i=0; i<cnt_supported_tokens; i++) {
            (address token_address, bool status) = marketDataOracle.getSupportedTokenByIndex(i);

            if (status) {
                
                uint256 _b1 = balanceOf(token_address, attackInfo.attacker);
                if (_b1 > 0) {
                    uint256 _w1 = _b1.mul(actualPrizeRation).div(attackPricePrecentBase * 100); 
                    attackInfo.attackeeWinnings[token_address] = _w1;
                }

                
                uint256 _b2 = balanceOf(token_address, attackInfo.attackee);
                if (_b2 > 0) {
                    uint256 _w2 = _b2.mul(actualPrizeRation).div(attackPricePrecentBase * 100); 
                    attackInfo.attackerWinnings[token_address] = _w2;
                }
            }
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function _calculateWinnerBasedOnEntropy(AttackInfo storage attackInfo, bytes32 entropy) view internal returns(address, uint) {
        uint attackeeActualScore = attackInfo.attackeeScore;
        uint modul = _absSubtraction(attackInfo.attackerScore, attackInfo.attackeeScore);
        modul = modul.mul(2); 
        uint hodlSpell = uint(entropy) % modul;
        uint direction = uint(entropy) % 10;
        uint directionThreshold = 1;

        
        
        if (attackInfo.attackerScore < attackInfo.attackeeScore) {
            directionThreshold = 8;
        }

        
        if (direction > directionThreshold) {
            attackeeActualScore = attackeeActualScore.add(hodlSpell);
        }
        else {
            attackeeActualScore = _safeSubtract(attackeeActualScore, hodlSpell);
        }
        if (attackInfo.attackerScore > attackeeActualScore) { return (attackInfo.attacker, attackeeActualScore); }
        else { return (attackInfo.attackee, attackeeActualScore); }
    }

    
    
    
    function _absSubtraction(uint a, uint b) pure internal returns (uint) {
        if (b>a) {
            return b-a;
        }

        return a-b;
    }

    
    
    function _safeSubtract(uint a, uint b) pure internal returns (uint) {
        if (b > a) {
            return 0;
        }

        return a-b;
    }
}