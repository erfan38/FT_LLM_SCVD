contract Slot is usingOraclize, EmergencyWithdrawalModule, DSMath {
    
    uint constant INVESTORS_EDGE = 200; 
    uint constant HOUSE_EDGE = 50;
    uint constant CAPITAL_RISK = 250;
    uint constant MAX_SPINS = 16;
    
    uint minBet = 1 wei;
 
    struct SpinsContainer {
        address playerAddress;
        uint nSpins;
        uint amountWagered;
    }
    
    mapping (bytes32 => SpinsContainer) spins;
    
    /* Both arrays are ordered:
     - probabilities are ordered from smallest to highest
     - multipliers are ordered from highest to lowest
     The probabilities are expressed as integer numbers over a scale of 10000: i.e
     100 is equivalent to 1%, 5000 to 50% and so on.
    */
    uint[] public probabilities;
    uint[] public multipliers;
    
    uint public totalAmountWagered; 
    
    event LOG_newSpinsContainer(bytes32 indexed myid, address indexed playerAddress, uint amountWagered, uint nSpins);
    event LOG_SpinExecuted(bytes32 indexed myid, address indexed playerAddress, uint spinIndex, uint numberDrawn, uint grossPayoutForSpin);
    event LOG_SpinsContainerInfo(bytes32 indexed myid, address indexed playerAddress, uint netPayout);

    LedgerProofVerifyI externalContract;
    
    function Slot(address _verifierAddr) {
        externalContract = LedgerProofVerifyI(_verifierAddr);
    }
    
    //SECTION I: MODIFIERS AND HELPER FUNCTIONS
    
    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {
        externalContract.external_oraclize_randomDS_setCommitment(queryId, commitment);
    }
    
    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {
        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)
        //if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) throw;
        assert(externalContract.external_oraclize_randomDS_proofVerify(_proof, _queryId, bytes(_result), oraclize_getNetworkName()));
        _;
    }

    modifier onlyOraclize {
        assert(msg.sender == oraclize_cbAddress());
        _;
    }

    modifier onlyIfSpinsExist(bytes32 myid) {
        assert(spins[myid].playerAddress != address(0x0));
        _;
    }
    
    function isValidSize(uint _amountWagered) 
        internal 
        returns(bool) {
            
        uint netPotentialPayout = (_amountWagered * (10000 - INVESTORS_EDGE) * multipliers[0])/ 10000; 
        uint maxAllowedPayout = (CAPITAL_RISK * getBankroll())/10000;
        
        return ((netPotentialPayout <= maxAllowedPayout) && (_amountWagered >= minBet));
    }

    modifier onlyIfEnoughFunds(bytes32 myid) {
        if (isValidSize(spins[myid].amountWagered)) {
             _;
        }
        else {
            address playerAddress = spins[myid].playerAddress;
            uint amountWagered = spins[myid].amountWagered;   
            delete spins[myid];
            safeSend(playerAddress, amountWagered);
            return;
        }
    }
    

        modifier onlyValidNumberOfSpins (uint _nSpins) {
        assert(_nSpins <= MAX_SPINS);
              assert(_nSpins > 0);
        _;
    }
    
    /*
        For the game to be fair, the total gross payout over a large number of 
        individual slot spins should be the total amount wagered by the player. 
        
        The game owner, called house, and the investors will gain by applying 
        a small fee, called edge, to the amount won by the player in the case of
        a successful spin. 
        
        The total gross expected payout is equal to the sum of all payout. Each 
        i-th payout is calculated:
                    amountWagered * multipliers[i] * probabilities[i] 
        The fairness condition can be expressed as the equation:
                    sum of aW * m[i] * p[i] = aW
        After having simplified the equation:
                        sum of m[i] * p[i] = 1
        Since our probabilities are defined over 10000, the sum should be 10000.
        
        The 