contract Etheroll is usingOraclize, DSSafeAddSub {
    
     using strings for *;

    /*
     * checks player profit, bet size and player number is within range
    */
    modifier betIsValid(uint _betSize, uint _playerNumber) {      
        if(((((_betSize * (100-(safeSub(_playerNumber,1)))) / (safeSub(_playerNumber,1))+_betSize))*houseEdge/houseEdgeDivisor)-_betSize > maxProfit || _betSize < minBet || _playerNumber < minNumber || _playerNumber > maxNumber) throw;        
		_;
    }

    /*
     * checks game is currently active
    */
    modifier gameIsActive {
        if(gamePaused == true) throw;
		_;
    }    

    /*
     * checks payouts are currently active
    */
    modifier payoutsAreActive {
        if(payoutsPaused == true) throw;
		_;
    }    

    /*
     * checks only Oraclize address is calling
    */
    modifier onlyOraclize {
        if (msg.sender != oraclize_cbAddress()) throw;
        _;
    }

    /*
     * checks only owner address is calling
    */
    modifier onlyOwner {
         if (msg.sender != owner) throw;
         _;
    }

    /*
     * checks only treasury address is calling
    */
    modifier onlyTreasury {
         if (msg.sender != treasury) throw;
         _;
    }    

    /*
     * game vars
    */ 
    uint constant public maxProfitDivisor = 1000000;
    uint constant public houseEdgeDivisor = 1000;    
    uint constant public maxNumber = 99; 
    uint constant public minNumber = 2;
	bool public gamePaused;
    uint32 public gasForOraclize;
    address public owner;
    bool public payoutsPaused; 
    address public treasury;
    uint public contractBalance;
    uint public houseEdge;     
    uint public maxProfit;   
    uint public maxProfitAsPercentOfHouse;                    
    uint public minBet;       
    int public totalBets;
    uint public maxPendingPayouts;
    uint public costToCallOraclizeInWei;
    uint public totalWeiWon;

    /*
     * player vars
    */
    mapping (bytes32 => address) playerAddress;
    mapping (bytes32 => address) playerTempAddress;
    mapping (bytes32 => bytes32) playerBetId;
    mapping (bytes32 => uint) playerBetValue;
    mapping (bytes32 => uint) playerTempBetValue;  
    mapping (bytes32 => uint) playerRandomResult;     
    mapping (bytes32 => uint) playerDieResult;
    mapping (bytes32 => uint) playerNumber;
    mapping (address => uint) playerPendingWithdrawals;      
    mapping (bytes32 => uint) playerProfit;
    mapping (bytes32 => uint) playerTempReward;    
        

    /*
     * events
    */
    /* log bets + output to web3 for precise 'payout on win' field in UI */
    event LogBet(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RewardValue, uint ProfitValue, uint BetValue, uint PlayerNumber);      
    /* output to web3 UI on bet result*/
    /* Status: 0=lose, 1=win, 2=win + failed send, 3=refund, 4=refund + failed send*/
	event LogResult(uint indexed ResultSerialNumber, bytes32 indexed BetID, address indexed PlayerAddress, uint PlayerNumber, uint DiceResult, uint Value, int Status, bytes Proof);   
    /* log manual refunds */
    event LogRefund(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RefundValue);
    /* log owner transfers */
    event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);               


    /*
     * init
    */
    function Etheroll() {

        owner = msg.sender;
        treasury = msg.sender;
        
        oraclize_setNetwork(networkID_auto);        
        /* use TLSNotary for oraclize call */
		oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        /* init 990 = 99% (1% houseEdge)*/
        ownerSetHouseEdge(990);
        /* init 10,000 = 1%  */
        ownerSetMaxProfitAsPercentOfHouse(10000);
        /* init min bet (0.1 ether) */
        ownerSetMinBet(100000000000000000);        
        /* init gas for oraclize */        
        gasForOraclize = 250000;        

    }

    /*
     * public function
     * player submit bet
     * only if game is active & bet is valid can query oraclize and set player vars     
    */
    function playerRollDice(uint rollUnder) public 
        payable
        gameIsActive
        betIsValid(msg.value, rollUnder)
	{        
        
        /*
        * assign partially encrypted query to oraclize
        * only the apiKey is encrypted 
        * integer query is in plain text
        */
        bytes32 rngId = oraclize_query("nested", "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\",\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":${[decrypt] BKjhlm6SfYJ79hWWmywPWdwaFHZCU9yBavQcnDLajf8Cbxo9W6z8KNnzmS+/0hmoNTnBRZxSgACLlIghH+Zm65EAhJCsE6q/W5YlR55o+HbGWyMEi0o5ngKy1MtUi49eg4HhelENzDMMEynC3eY6SeJeQNe4NsE=},\"n\":1,\"min\":1,\"max\":100,\"replacement\":true,\"base\":10${[identity] \"}\"},\"id\":1${[identity] \"}\"}']", gasForOraclize);
        
        /* safely update 