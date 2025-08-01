contract Dice is usingOraclize {

    uint public pwin = 5000; //probability of winning (10000 = 100%)
    uint public edge = 200; //edge percentage (10000 = 100%)
    uint public maxWin = 100; //max win (before edge is taken) as percentage of bankroll (10000 = 100%)
    uint public minBet = 1 finney;
    uint public maxInvestors = 5; //maximum number of investors
    uint public houseEdge = 50; //edge percentage (10000 = 100%)
    uint public divestFee = 50; //divest fee percentage (10000 = 100%)
    uint public emergencyWithdrawalRatio = 90; //ratio percentage (100 = 100%)

    uint safeGas = 25000;
    uint constant ORACLIZE_GAS_LIMIT = 125000;
    uint constant INVALID_BET_MARKER = 99999;
    uint constant EMERGENCY_TIMEOUT = 7 days;

    struct Investor {
        address investorAddress;
        uint amountInvested;
        bool votedForEmergencyWithdrawal;
    }

    struct Bet {
        address playerAddress;
        uint amountBetted;
        uint numberRolled;
    }

    struct WithdrawalProposal {
        address toAddress;
        uint atTime;
    }

    //Starting at 1
    mapping(address => uint) investorIDs;
    mapping(uint => Investor) investors;
    uint public numInvestors = 0;

    uint public invested = 0;

    address owner;
    address houseAddress;
    bool public isStopped;

    WithdrawalProposal proposedWithdrawal;

    mapping (bytes32 => Bet) bets;
    bytes32[] betsKeys;

    uint public amountWagered = 0;
    uint public investorsProfit = 0;
    uint public investorsLoses = 0;
    bool profitDistributed;

    event BetWon(address playerAddress, uint numberRolled, uint amountWon);
    event BetLost(address playerAddress, uint numberRolled);
    event EmergencyWithdrawalProposed();
    event EmergencyWithdrawalFailed(address withdrawalAddress);
    event EmergencyWithdrawalSucceeded(address withdrawalAddress, uint amountWithdrawn);
    event FailedSend(address receiver, uint amount);
    event ValueIsTooBig();

    function Dice(uint pwinInitial,
                  uint edgeInitial,
                  uint maxWinInitial,
                  uint minBetInitial,
                  uint maxInvestorsInitial,
                  uint houseEdgeInitial,
                  uint divestFeeInitial,
                  uint emergencyWithdrawalRatioInitial
                  ) {

        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);

        pwin = pwinInitial;
        edge = edgeInitial;
        maxWin = maxWinInitial;
        minBet = minBetInitial;
        maxInvestors = maxInvestorsInitial;
        houseEdge = houseEdgeInitial;
        divestFee = divestFeeInitial;
        emergencyWithdrawalRatio = emergencyWithdrawalRatioInitial;
        owner = msg.sender;
        houseAddress = msg.sender;
    }

    //SECTION I: MODIFIERS AND HELPER FUNCTIONS

    //MODIFIERS

    modifier onlyIfNotStopped {
        if (isStopped) throw;
        _
    }

    modifier onlyIfStopped {
        if (!isStopped) throw;
        _
    }

    modifier onlyInvestors {
        if (investorIDs[msg.sender] == 0) throw;
        _
    }

    modifier onlyNotInvestors {
        if (investorIDs[msg.sender] != 0) throw;
        _
    }

    modifier onlyOwner {
        if (owner != msg.sender) throw;
        _
    }

    modifier onlyOraclize {
        if (msg.sender != oraclize_cbAddress()) throw;
        _
    }

    modifier onlyMoreThanMinInvestment {
        if (msg.value <= getMinInvestment()) throw;
        _
    }

    modifier onlyMoreThanZero {
        if (msg.value == 0) throw;
        _
    }

    modifier onlyIfBetSizeIsStillCorrect(bytes32 myid) {
        Bet thisBet = bets[myid];
        if ((((thisBet.amountBetted * ((10000 - edge) - pwin)) / pwin ) <= (maxWin * getBankroll()) / 10000)) {
             _
        }
        else {
            bets[myid].numberRolled = INVALID_BET_MARKER;
            safeSend(thisBet.playerAddress, thisBet.amountBetted);
            return;
        }
    }

    modifier onlyIfValidRoll(bytes32 myid, string result) {
        Bet thisBet = bets[myid];
        uint numberRolled = parseInt(result);
        if ((numberRolled < 1 || numberRolled > 10000) && thisBet.numberRolled == 0) {
            bets[myid].numberRolled = INVALID_BET_MARKER;
            safeSend(thisBet.playerAddress, thisBet.amountBetted);
            return;
        }
        _
    }

    modifier onlyIfInvestorBalanceIsPositive(address currentInvestor) {
        if (getBalance(currentInvestor) >= 0) {
            _
        }
    }

    modifier onlyWinningBets(uint numberRolled) {
        if (numberRolled - 1 < pwin) {
            _
        }
    }

    modifier onlyLosingBets(uint numberRolled) {
        if (numberRolled - 1 >= pwin) {
            _
        }
    }

    modifier onlyAfterProposed {
        if (proposedWithdrawal.toAddress == 0) throw;
        _
    }

    modifier rejectValue {
        if (msg.value != 0) throw;
        _
    }

    modifier onlyIfProfitNotDistributed {
        if (!profitDistributed) {
            _
        }
    }

    modifier onlyIfValidGas(uint newGasLimit) {
        if (newGasLimit < 25000) throw;
        _
    }

    modifier onlyIfNotProcessed(bytes32 myid) {
        Bet thisBet = bets[myid];
        if (thisBet.numberRolled > 0) throw;
        _
    }

    modifier onlyIfEmergencyTimeOutHasPassed {
        if (proposedWithdrawal.atTime + EMERGENCY_TIMEOUT > now) throw;
        _
    }


    //CONSTANT HELPER FUNCTIONS

    function getBankroll() constant returns(uint) {
        return invested + investorsProfit - investorsLoses;
    }

    function getMinInvestment() constant returns(uint) {
        if (numInvestors == maxInvestors) {
            uint investorID = searchSmallestInvestor();
            return getBalance(investors[investorID].investorAddress);
        }
        else {
            return 0;
        }
    }

    function getStatus() constant returns(uint, uint, uint, uint, uint, uint, uint, uint, uint) {

        uint bankroll = getBankroll();

        if (this.balance < bankroll) {
            bankroll = this.balance;
        }

        uint minInvestment = getMinInvestment();

        return (bankroll, pwin, edge, maxWin, minBet, amountWagered, (investorsProfit - investorsLoses), minInvestment, betsKeys.length);
    }

    function getBet(uint id) constant returns(address, uint, uint) {
        if (id < betsKeys.length) {
            bytes32 betKey = betsKeys[id];
            return (bets[betKey].playerAddress, bets[betKey].amountBetted, bets[betKey].numberRolled);
        }
    }

    function numBets() constant returns(uint) {
        return betsKeys.length;
    }

    function getMinBetAmount() constant returns(uint) {
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        return oraclizeFee + minBet;
    }

    function getMaxBetAmount() constant returns(uint) {
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        uint betValue =  (maxWin * getBankroll()) * pwin / (10000 * (10000 - edge - pwin));
        return betValue + oraclizeFee;
    }

    function getLosesShare(address currentInvestor) constant returns (uint) {
        return investors[investorIDs[currentInvestor]].amountInvested * (investorsLoses) / invested;
    }

    function getProfitShare(address currentInvestor) constant returns (uint) {
        return investors[investorIDs[currentInvestor]].amountInvested * (investorsProfit) / invested;
    }

    function getBalance(address currentInvestor) constant returns (uint) {
        return investors[investorIDs[currentInvestor]].amountInvested + getProfitShare(currentInvestor) - getLosesShare(currentInvestor);
    }

    // PRIVATE HELPERS FUNCTION

    function searchSmallestInvestor() private returns(uint) {
        uint investorID = 1;
        for (uint i = 1; i <= numInvestors; i++) {
            if (getBalance(investors[i].investorAddress) < getBalance(investors[investorID].investorAddress)) {
                investorID = i;
            }
        }

        return investorID;
    }

    function safeSend(address addr, uint value) private {
        if (this.balance < value) {
            ValueIsTooBig();
            return;
        }

        if (!(addr.call.gas(safeGas).value(value)())) {
            FailedSend(addr, value);
            if (addr != houseAddress) {
                //Forward to house address all change
                if (!(houseAddress.call.gas(safeGas).value(value)())) FailedSend(houseAddress, value);
            }
        }
    }

    function addInvestorAtID(uint id) private {
        investorIDs[msg.sender] = id;
        investors[id].investorAddress = msg.sender;
        investors[id].amountInvested = msg.value;
        invested += msg.value;
    }

    function profitDistribution() private onlyIfProfitNotDistributed {
        uint copyInvested;

        for (uint i = 1; i <= numInvestors; i++) {
            address currentInvestor = investors[i].investorAddress;
            uint profitOfInvestor = getProfitShare(currentInvestor);
            uint losesOfInvestor = getLosesShare(currentInvestor);
            investors[i].amountInvested += profitOfInvestor - losesOfInvestor;
            copyInvested += investors[i].amountInvested;
        }

        delete investorsProfit;
        delete investorsLoses;
        invested = copyInvested;

        profitDistributed = true;
    }

    // SECTION II: BET & BET PROCESSING

    function() {
        bet();
    }

    function bet() onlyIfNotStopped onlyMoreThanZero {
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        uint betValue = msg.value - oraclizeFee;
        if ((((betValue * ((10000 - edge) - pwin)) / pwin ) <= (maxWin * getBankroll()) / 10000) && (betValue >= minBet)) {
            // encrypted arg: '\n{"jsonrpc":2.0,"method":"generateSignedIntegers","params":{"apiKey":"YOUR_API_KEY","n":1,"min":1,"max":10000},"id":1}'
            bytes32 myid = oraclize_query("URL", "json(https://api.random.org/json-rpc/1/invoke).result.random.data.0","BKniCJx8z96RVCJ9FCMlku5t4lEAbCqQS2jF1W41eQLA10mPNC4RYGMkQfWcfvZKlOmpVVhMXiwa6a9ledKfelRiupoMeJxLo2mMapQpo9FY319mSyxFCm9YvW7iNy6Sy+tFDFWWRpTUKqm95GKj93us6eBMACXICmGk8ppy5AA7mmE//xYXnWrniVWtFSuizOy5SO5c4jC8Y9GHNoyBMUHHpbLEHbnzp5NcXEj8VUWvycqA1s24CFDaC4avZsENX8ruVtDKQfuHG2l/vZLY2p6RPaFOYVS6xMQiJ3qS/U0=", ORACLIZE_GAS_LIMIT + safeGas);
            bets[myid] = Bet(msg.sender, betValue, 0);
            betsKeys.push(myid);
        }
        else {
            throw;
        }
    }

    function __callback (bytes32 myid, string result, bytes proof)
        onlyOraclize
        onlyIfNotProcessed(myid)
        onlyIfValidRoll(myid, result)
        onlyIfBetSizeIsStillCorrect(myid)  {

        Bet thisBet = bets[myid];
        uint numberRolled = parseInt(result);
        bets[myid].numberRolled = numberRolled;
        isWinningBet(thisBet, numberRolled);
        isLosingBet(thisBet, numberRolled);
        amountWagered += thisBet.amountBetted;
        delete profitDistributed;
    }

    function isWinningBet(Bet thisBet, uint numberRolled) private onlyWinningBets(numberRolled) {
        uint winAmount = (thisBet.amountBetted * (10000 - edge)) / pwin;
        BetWon(thisBet.playerAddress, numberRolled, winAmount);
        safeSend(thisBet.playerAddress, winAmount);
        investorsLoses += (winAmount - thisBet.amountBetted);
    }

    function isLosingBet(Bet thisBet, uint numberRolled) private onlyLosingBets(numberRolled) {
        BetLost(thisBet.playerAddress, numberRolled);
        safeSend(thisBet.playerAddress, 1);
        investorsProfit += (thisBet.amountBetted - 1)*(10000 - houseEdge)/10000;
        uint houseProfit = (thisBet.amountBetted - 1)*(houseEdge)/10000;
        safeSend(houseAddress, houseProfit);
    }

    //SECTION III: INVEST & DIVEST

    function increaseInvestment() onlyIfNotStopped onlyMoreThanZero onlyInvestors  {
        profitDistribution();
        investors[investorIDs[msg.sender]].amountInvested += msg.value;
        invested += msg.value;
    }

    function newInvestor()
        onlyIfNotStopped
        onlyMoreThanZero
        onlyNotInvestors
        onlyMoreThanMinInvestment {
        profitDistribution();

        if (numInvestors < maxInvestors) {
            numInvestors++;
            addInvestorAtID(numInvestors);
        }
        else {
            uint smallestInvestorID = searchSmallestInvestor();
            divest(investors[smallestInvestorID].investorAddress);
            addInvestorAtID(smallestInvestorID);
            numInvestors++;
        }
    }

    function divest() onlyInvestors rejectValue {
        divest(msg.sender);
    }

    function divest(address currentInvestor)
        private
        onlyIfInvestorBalanceIsPositive(currentInvestor) {

        profitDistribution();
        uint currentID = investorIDs[currentInvestor];
        uint amountToReturn = getBalance(currentInvestor);
        invested -= investors[currentID].amountInvested;
        uint divestFeeAmount =  (amountToReturn*divestFee)/10000;
        amountToReturn -= divestFeeAmount;
        //Clean up
        numInvestors--;
        delete investors[currentID];
        delete investorIDs[currentInvestor];
        safeSend(currentInvestor, amountToReturn);
        safeSend(houseAddress, divestFeeAmount);
    }

    function forceDivestOfAllInvestors() onlyOwner rejectValue {
        uint copyNumInvestors = numInvestors;
        for (uint investorID = 1; investorID <= copyNumInvestors; investorID++) {
            divest(investors[investorID].investorAddress);
        }
    }

    /*
    The owner can use this function to force the exit of an investor from the
    