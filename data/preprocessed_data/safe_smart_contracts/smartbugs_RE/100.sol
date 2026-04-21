pragma solidity^0.4.24;










interface MobiusToken {
    function disburseDividends() external payable;
}

interface LastVersion {
    function withdrawReturns() external;
    function roundInfo(uint roundID) external view 
    returns(
        address leader, 
        uint price,
        uint jackpot, 
        uint airdrop, 
        uint shares, 
        uint totalInvested,
        uint distributedReturns,
        uint _hardDeadline,
        uint _softDeadline,
        bool finalized
        );
    function totalsInfo() external view 
    returns(
        uint totalReturns,
        uint totalShares,
        uint totalDividends,
        uint totalJackpots
    );
    function latestRoundID() external returns(uint);
}





























































 
contract Mobius2Dv2 is UsingOraclizeRandom, DSMath {
    
    
    string public ipfsHash;
    string public ipfsHashType = "ipfs"; 

    MobiusToken public constant token = MobiusToken(0x54cdC9D889c28f55F59f6b136822868c7d4726fC);

    
    
    bool public upgraded;
    bool public initialized;
    address public nextVersion;
    LastVersion public constant lastVersion = LastVersion(0xA74642Aeae3e2Fd79150c910eB5368B64f864B1e);
    uint public previousRounds;

    
    uint public totalRevenue;
    uint public totalSharesSold;
    uint public totalEarningsGenerated;
    uint public totalDividendsPaid;
    uint public totalJackpotsWon;

    
    uint public constant DEV_DIVISOR = 20;                      

    uint public constant RETURNS_FRACTION = 60 * 10**16;        
    
    uint public constant REFERRAL_FRACTION = 3 * 10**16;        

    uint public constant JACKPOT_SEED_FRACTION = WAD / 20;      
    uint public constant JACKPOT_FRACTION = 15 * 10**16;        
    uint public constant DAILY_JACKPOT_FRACTION = 6 * 10**16;    
    uint public constant DIVIDENDS_FRACTION = 9 * 10**16;       

    
    uint public startingSharePrice = 1 finney;   
    uint public _priceIncreasePeriod = 1 hours;  
    uint public _priceMultiplier = 101 * 10**16; 

    uint public _secondaryPrice = 100 finney;    
    uint public maxDailyJackpot = 5 ether; 

    uint public constant SOFT_DEADLINE_DURATION = 1 days; 
    uint public constant DAILY_JACKPOT_PERIOD = 1 days;
    uint public constant TIME_PER_SHARE = 5 minutes; 

    uint public nextRoundTime; 
    uint public jackpotSeed;
    uint public devBalance; 

    
    uint public unclaimedReturns;
    uint public constant MULTIPLIER = RAY;

    
    mapping (address => uint) public lastDailyEntry;

    
    
    struct Investor {
        uint lastCumulativeReturnsPoints;
        uint shares;
    }

    
    struct MobiusRound {
        uint totalInvested;        
        uint jackpot;
        uint dailyJackpot;
        uint totalShares;
        uint cumulativeReturnsPoints; 
        uint softDeadline;
        uint price;
        uint secondaryPrice;
        uint priceMultiplier;
        uint priceIncreasePeriod;
        uint lastPriceIncreaseTime;
        uint lastDailyJackpot;
        address lastInvestor;
        bool finalized;
        mapping (address => Investor) investors;
    }

    struct DailyJackpotRound {
        address[] entrants;
        address winner;
        bool finalized;
    }

    struct Vault {
        uint totalReturns; 
        uint refReturns; 
    }

    mapping (address => Vault) vaults;

    uint public latestRoundID;
    uint public latestDailyID;
    MobiusRound[] rounds;
    DailyJackpotRound[] dailyRounds;

    event SharesIssued(address indexed to, uint shares);
    event ReturnsWithdrawn(address indexed by, uint amount);
    event JackpotWon(address by, uint amount);
    event DailyJackpotWon(address indexed by, uint amount);
    event RoundStarted(uint ID, uint startingPrice, uint priceMultiplier, uint priceIncreasePeriod);
    event IPFSHashSet(string _type, string _hash);

    constructor() public {
    }

    function initOraclize() public auth {
        oraclizeCallbackGas = 250000;
        if(oraclize_setNetwork()){
            oraclize_setProof(proofType_Ledger);
        }
    }

    
    
    function estimateReturns(address investor, uint roundID) public view 
    returns (uint totalReturns, uint refReturns) 
    {
        MobiusRound storage rnd = rounds[roundID];
        uint outstanding;
        if(rounds.length > 1) {
            if(hasReturns(investor, roundID - 1)) {
                MobiusRound storage prevRnd = rounds[roundID - 1];
                outstanding = _outstandingReturns(investor, prevRnd);
            }
        }

        outstanding += _outstandingReturns(investor, rnd);
        
        totalReturns = vaults[investor].totalReturns + outstanding;
        refReturns = vaults[investor].refReturns;
    }

    function hasReturns(address investor, uint roundID) public view returns (bool) {
        MobiusRound storage rnd = rounds[roundID];
        return rnd.cumulativeReturnsPoints > rnd.investors[investor].lastCumulativeReturnsPoints;
    }

    function investorInfo(address investor, uint roundID) external view
    returns(uint shares, uint totalReturns, uint referralReturns, bool inNextDailyDraw) 
    {
        MobiusRound storage rnd = rounds[roundID];
        shares = rnd.investors[investor].shares;
        (totalReturns, referralReturns) = estimateReturns(investor, roundID);
        inNextDailyDraw = lastDailyEntry[investor] > rnd.lastDailyJackpot;
    }

    function roundInfo(uint roundID) external view 
    returns(
        address leader, 
        uint price,
        uint secondaryPrice,
        uint priceMultiplier,
        uint priceIncreasePeriod,
        uint jackpot, 
        uint dailyJackpot, 
        uint lastDailyJackpot,
        uint shares, 
        uint totalInvested,
        uint distributedReturns,
        uint _softDeadline,
        bool finalized
        )
    {
        MobiusRound storage rnd = rounds[roundID];
        leader = rnd.lastInvestor;
        price = rnd.price;
        secondaryPrice = _secondaryPrice;
        priceMultiplier = rnd.priceMultiplier;
        priceIncreasePeriod = rnd.priceIncreasePeriod;
        jackpot = rnd.jackpot;
        dailyJackpot = min(maxDailyJackpot, rnd.dailyJackpot/2);
        lastDailyJackpot = rnd.lastDailyJackpot;
        shares = rnd.totalShares;
        totalInvested = rnd.totalInvested;
        distributedReturns = wmul(rnd.totalInvested, RETURNS_FRACTION);
        _softDeadline = rnd.softDeadline;
        finalized = rnd.finalized;
    }

    function totalsInfo() external view 
    returns(
        uint totalReturns,
        uint totalShares,
        uint totalDividends,
        uint totalJackpots,
        uint totalInvested,
        uint totalRounds
    ) {
        MobiusRound storage rnd = rounds[latestRoundID];
        if(rnd.softDeadline > now) {
            totalShares = totalSharesSold + rnd.totalShares;
            totalReturns = totalEarningsGenerated + wmul(rnd.totalInvested, RETURNS_FRACTION);
            totalDividends = totalDividendsPaid + wmul(rnd.totalInvested, DIVIDENDS_FRACTION);
            totalInvested = totalRevenue + rnd.totalInvested;
        } else {
            totalShares = totalSharesSold;
            totalReturns = totalEarningsGenerated;
            totalDividends = totalDividendsPaid;
            totalInvested = totalRevenue;
        }
        totalJackpots = totalJackpotsWon;
        totalRounds = previousRounds + rounds.length;
    }

    function () public payable {
        if(!initialized){
            jackpotSeed += msg.value;
        } else {
            buyShares(address(0x0));
        }
    }

    
    function buyShares(address ref) public payable {        
        if(rounds.length > 0) {
            MobiusRound storage rnd = rounds[latestRoundID];                  
            _purchase(rnd, msg.value, ref);            
        } else {
            revert("Not yet started");
        }
    }

    
    function reinvestReturns(uint value) public {        
        reinvestReturns(value, address(0x0));
    }

    function reinvestReturns(uint value, address ref) public {        
        MobiusRound storage rnd = rounds[latestRoundID];
        _updateReturns(msg.sender, rnd);        
        require(vaults[msg.sender].totalReturns >= value, "Can't spend what you don't have");        
        vaults[msg.sender].totalReturns = sub(vaults[msg.sender].totalReturns, value);
        vaults[msg.sender].refReturns = min(vaults[msg.sender].refReturns, vaults[msg.sender].totalReturns);
        unclaimedReturns = sub(unclaimedReturns, value);
        _purchase(rnd, value, ref);
    }

    function withdrawReturns() public {
        MobiusRound storage rnd = rounds[latestRoundID];

        if(rounds.length > 1) {
            if(hasReturns(msg.sender, latestRoundID - 1)) {
                MobiusRound storage prevRnd = rounds[latestRoundID - 1];
                _updateReturns(msg.sender, prevRnd);
            }
        }
        _updateReturns(msg.sender, rnd);
        uint amount = vaults[msg.sender].totalReturns;
        require(amount > 0, "Nothing to withdraw!");
        unclaimedReturns = sub(unclaimedReturns, amount);
        vaults[msg.sender].totalReturns = 0;
        vaults[msg.sender].refReturns = 0;
        
        rnd.investors[msg.sender].lastCumulativeReturnsPoints = rnd.cumulativeReturnsPoints;
        msg.sender.transfer(amount);

        emit ReturnsWithdrawn(msg.sender, amount);
    }

    
    function updateMyReturns(uint roundID) public {
        MobiusRound storage rnd = rounds[roundID];
        _updateReturns(msg.sender, rnd);
    }

    function finalizeAndRestart() public payable {
        finalizeLastRound();
        startNewRound();
    }

    
    function startNewRound() public payable {
        require(!upgraded && initialized, "This contract has been upgraded, or is not yet initialized!");
        require(now >= nextRoundTime, "Too early!");
        if(rounds.length > 0) {
            require(rounds[latestRoundID].finalized, "Previous round not finalized");
            require(rounds[latestRoundID].softDeadline < now, "Previous round still running");
        }
        uint _rID = rounds.length++;
        MobiusRound storage rnd = rounds[_rID];
        latestRoundID = _rID;

        rnd.lastInvestor = msg.sender;
        rnd.price = startingSharePrice;
        rnd.secondaryPrice = _secondaryPrice;
        rnd.priceMultiplier = _priceMultiplier;
        rnd.priceIncreasePeriod = _priceIncreasePeriod;
        rnd.lastPriceIncreaseTime = now;
        rnd.lastDailyJackpot = now;
        rnd.softDeadline = now + SOFT_DEADLINE_DURATION;
        rnd.jackpot = jackpotSeed;
        jackpotSeed = 0; 
        _startNewDailyRound();
        _purchase(rnd, msg.value, address(0x0));
        emit RoundStarted(_rID, startingSharePrice, _priceMultiplier, _priceIncreasePeriod);
    }

    
    function finalizeLastRound() public {
        MobiusRound storage rnd = rounds[latestRoundID];
        _finalizeRound(rnd);
    }

    function setRoundParams(uint startingPrice, uint priceMultiplier, uint priceIncreasePeriod) public auth {
        startingSharePrice = startingPrice;
        _priceMultiplier = priceMultiplier;
        _priceIncreasePeriod = priceIncreasePeriod;
    }

    function setSecondaryPrice(uint newPrice) public auth {
        _secondaryPrice = newPrice;
    }

    function setMaxDailyJackpot(uint newLimit) public auth {
        maxDailyJackpot = newLimit;
    }

    
    function setNextRoundTimestamp(uint timestamp) public auth {
        require(now > nextRoundTime);
        require(timestamp <= now + 2 days);
        nextRoundTime = timestamp;
    }

    function setNextRoundDelay(uint delayInSeconds) public auth {
        require(now > nextRoundTime);
        require(now + delayInSeconds <= now + 2 days);
        nextRoundTime = now + delayInSeconds;
    }
    
    
    function withdrawDevShare() public auth {
        uint value = sub(devBalance, totalPaidOraclize); 
        devBalance = 0;
        totalPaidOraclize = 0;
        msg.sender.transfer(value);
    }

    function setIPFSHash(string _type, string _hash) public auth {
        ipfsHashType = _type;
        ipfsHash = _hash;
        emit IPFSHashSet(_type, _hash);
    }

    function upgrade(address _nextVersion) public auth {
        require(_nextVersion != address(0x0), "Invalid Address!");
        require(!upgraded, "Already upgraded!");
        upgraded = true;
        nextVersion = _nextVersion;
    }

    
    function getSeed() public {
        require(upgraded, "Not upgraded!");
        require(msg.sender == nextVersion, "You can't do that!");
        MobiusRound storage rnd = rounds[latestRoundID];
        require(rnd.finalized, "Still running!");
        
        require(nextVersion.call.value(jackpotSeed)(), "Transfer failed!");
    }

    
    
    function init() public auth {
        
        require(!initialized, "Already initialized!");
        uint _rID = lastVersion.latestRoundID();
        previousRounds = 1 + _rID;
        uint _shares;
        uint _invested;
        uint _returns;
        uint _dividends;
        uint _jackpots;
        bool finalized;
        ( , , , , , _invested, , , , finalized) = lastVersion.roundInfo(_rID);
        require(finalized, "Last round is still not finalized!");
        (_returns, _shares, _dividends, _jackpots) = lastVersion.totalsInfo();

        totalSharesSold = _shares;
        totalRevenue = _invested;
        totalEarningsGenerated = _returns;
        totalDividendsPaid = _dividends;
        totalJackpotsWon = _jackpots;
        
        
        
        initialized = true;
    }

    function _startNewDailyRound() internal {
        if(dailyRounds.length > 0) {
            require(dailyRounds[latestDailyID].finalized, "Previous round not finalized");
        }
        uint _rID = dailyRounds.length++;
        latestDailyID = _rID;
    }

    
    function _purchase(MobiusRound storage rnd, uint value, address ref) internal {
        require(rnd.softDeadline >= now, "After deadline!");
        require(value >= 100 szabo, "Not enough Ether!");
        rnd.totalInvested = add(rnd.totalInvested, value);

        
        if(value >= rnd.price) {
            rnd.lastInvestor = msg.sender;
        }
        
        _dailyJackpot(rnd, value);
        
        _splitRevenue(rnd, value, ref);
        
        _updateReturns(msg.sender, rnd);
        
        uint newShares = _issueShares(rnd, msg.sender, value);

        uint timeIncreases = newShares/WAD;
        
        uint newDeadline = add(rnd.softDeadline, mul(timeIncreases, TIME_PER_SHARE));
        rnd.softDeadline = min(newDeadline, now + SOFT_DEADLINE_DURATION);
        
        
        if(now > rnd.lastPriceIncreaseTime + rnd.priceIncreasePeriod) {
            rnd.price = wmul(rnd.price, rnd.priceMultiplier);
            rnd.lastPriceIncreaseTime = now;
        }
        
    }

    function _finalizeRound(MobiusRound storage rnd) internal {
        require(!rnd.finalized, "Already finalized!");
        require(rnd.softDeadline < now, "Round still running!");

        
        vaults[rnd.lastInvestor].totalReturns = add(vaults[rnd.lastInvestor].totalReturns, rnd.jackpot);
        unclaimedReturns = add(unclaimedReturns, rnd.jackpot);
        
        emit JackpotWon(rnd.lastInvestor, rnd.jackpot);
        totalJackpotsWon += rnd.jackpot;
        
        jackpotSeed = add(jackpotSeed, wmul(rnd.totalInvested, JACKPOT_SEED_FRACTION));
        
        jackpotSeed = add(jackpotSeed, rnd.dailyJackpot);
               
        
        uint _div = wmul(rnd.totalInvested, DIVIDENDS_FRACTION);            
        
        token.disburseDividends.value(_div)();
        totalDividendsPaid += _div;
        totalSharesSold += rnd.totalShares;
        totalEarningsGenerated += wmul(rnd.totalInvested, RETURNS_FRACTION);
        totalRevenue += rnd.totalInvested;
        dailyRounds[latestDailyID].finalized = true;
        rnd.finalized = true;
    }

    



    function _updateReturns(address _investor, MobiusRound storage rnd) internal {
        if(rnd.investors[_investor].shares == 0) {
            return;
        }
        
        uint outstanding = _outstandingReturns(_investor, rnd);

        
        if (outstanding > 0) {
            vaults[_investor].totalReturns = add(vaults[_investor].totalReturns, outstanding);
        }

        rnd.investors[_investor].lastCumulativeReturnsPoints = rnd.cumulativeReturnsPoints;
    }

    function _outstandingReturns(address _investor, MobiusRound storage rnd) internal view returns(uint) {
        if(rnd.investors[_investor].shares == 0) {
            return 0;
        }
        
        uint newReturns = sub(
            rnd.cumulativeReturnsPoints, 
            rnd.investors[_investor].lastCumulativeReturnsPoints
            );

        uint outstanding = 0;
        if(newReturns != 0) { 
            
            
            outstanding = mul(newReturns, rnd.investors[_investor].shares) / MULTIPLIER;
        }

        return outstanding;
    }

    
    function _splitRevenue(MobiusRound storage rnd, uint value, address ref) internal {
        uint roundReturns;
        
        if(ref != address(0x0) && ref != msg.sender) {
            
            roundReturns = wmul(value, RETURNS_FRACTION - REFERRAL_FRACTION);
            uint _ref = wmul(value, REFERRAL_FRACTION);
            vaults[ref].totalReturns = add(vaults[ref].totalReturns, _ref);            
            vaults[ref].refReturns = add(vaults[ref].refReturns, _ref);
            unclaimedReturns = add(unclaimedReturns, _ref);
        } else {
            roundReturns = wmul(value, RETURNS_FRACTION);
        }
        
        uint dailyJackpot = wmul(value, DAILY_JACKPOT_FRACTION);
        uint jackpot = wmul(value, JACKPOT_FRACTION);
        
        uint dev;
        
        dev = value / DEV_DIVISOR;
        
        
        if(rnd.totalShares == 0) {
            rnd.jackpot = add(rnd.jackpot, roundReturns);
        } else {
            _disburseReturns(rnd, roundReturns);
        }
        
        rnd.dailyJackpot = add(rnd.dailyJackpot, dailyJackpot);
        rnd.jackpot = add(rnd.jackpot, jackpot);
        devBalance = add(devBalance, dev);
    }

    function _disburseReturns(MobiusRound storage rnd, uint value) internal {
        unclaimedReturns = add(unclaimedReturns, value);
        
        
        if(rnd.totalShares == 0) {
            rnd.cumulativeReturnsPoints = mul(value, MULTIPLIER) / wdiv(value, rnd.price);
        } else {
            rnd.cumulativeReturnsPoints = add(
                rnd.cumulativeReturnsPoints, 
                mul(value, MULTIPLIER) / rnd.totalShares
            );
        }
    }

    function _issueShares(MobiusRound storage rnd, address _investor, uint value) internal returns(uint) {    
        if(rnd.investors[_investor].lastCumulativeReturnsPoints == 0) {
            rnd.investors[_investor].lastCumulativeReturnsPoints = rnd.cumulativeReturnsPoints;
        }    
        
        uint newShares = wdiv(value, rnd.price);
        
        
        if(value >= 100 ether) {
            newShares = mul(newShares, 2);
        } else if(value >= 10 ether) {
            newShares = add(newShares, newShares/2);
        } else if(value >= 1 ether) {
            newShares = add(newShares, newShares/3);
        } else if(value >= 100 finney) {
            newShares = add(newShares, newShares/10);
        }

        rnd.investors[_investor].shares = add(rnd.investors[_investor].shares, newShares);
        rnd.totalShares = add(rnd.totalShares, newShares);
        emit SharesIssued(_investor, newShares);
        return newShares;
    }    

    function _dailyJackpot(MobiusRound storage rnd, uint value) internal {
        
        if(value >= rnd.secondaryPrice) {
            dailyRounds[latestDailyID].entrants.push(msg.sender);
            lastDailyEntry[msg.sender] = now; 
        }
        
        if(now > rnd.lastDailyJackpot + DAILY_JACKPOT_PERIOD) {
            
            if(rnd.dailyJackpot < rnd.secondaryPrice * 4) {
                return;
            }
            if(!oraclizePending) {                
                _requestRandom(0);
            } else {
                if(now > oraclizeLastRequestTime + 10 minutes){
                    
                    
                    oraclizeGasPrice = min(150000000000, oraclizeGasPrice * 2); 
                    oraclize_setCustomGasPrice(oraclizeGasPrice);
                }
            }
        }
    }

    
    function _onRandom(uint _rand, bytes32 _queryId) internal {
        MobiusRound storage rnd = rounds[latestRoundID];
        
        if(rnd.softDeadline >= now && now > rnd.lastDailyJackpot + DAILY_JACKPOT_PERIOD) {
            _drawDailyJackpot(dailyRounds[latestDailyID], rnd, _rand);
        }
    }

    event FailedRNGVerification(bytes32 qID);

    function _onRandomFailed(bytes32 _queryId) internal {
        emit FailedRNGVerification(_queryId);
    }

    
    function _triggerOraclize() public auth {
        _requestRandom(0);
    }

    function _drawDailyJackpot(DailyJackpotRound storage dRnd, MobiusRound storage rnd, uint _rand) internal {
        if(dRnd.entrants.length != 0){
            uint winner = _rand % dRnd.entrants.length;
            uint prize = min(maxDailyJackpot, rnd.dailyJackpot / 2);
            rnd.dailyJackpot = sub(rnd.dailyJackpot, prize);
            vaults[dRnd.entrants[winner]].totalReturns = add(vaults[dRnd.entrants[winner]].totalReturns, prize);
            emit DailyJackpotWon(dRnd.entrants[winner], prize);
            dRnd.finalized = true;       
            unclaimedReturns = add(unclaimedReturns, prize);
            totalJackpotsWon += prize;

            _startNewDailyRound();
        }        
        rnd.lastDailyJackpot = now; 
    }

}