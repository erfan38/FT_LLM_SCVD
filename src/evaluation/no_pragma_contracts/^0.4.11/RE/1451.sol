contract TokenTracker {
  // Share of formerly restricted tokens among all tokens in percent 
  uint public restrictedShare; 

  // Mapping from address to number of tokens assigned to the address
  mapping(address => uint) public tokens;

  // Mapping from address to number of tokens assigned to the address that
  // underly a restriction
  mapping(address => uint) public restrictions;
  
  // Total number of (un)restricted tokens currently in existence
  uint public totalRestrictedTokens; 
  uint public totalUnrestrictedTokens; 
  
  // Total number of individual assignment calls have been for (un)restricted
  // tokens
  uint public totalRestrictedAssignments; 
  uint public totalUnrestrictedAssignments; 

  // State flag. Assignments can only be made if false. 
  // Starting the conversion (burn) process irreversibly sets this to true. 
  bool public assignmentsClosed = false;
  
  // The multiplier (defined by nominator and denominator) that defines the
  // fraction of all restricted tokens to be burned. 
  // This is computed after assignments have ended and before the conversion
  // process starts.
  uint public burnMultDen;
  uint public burnMultNom;

  function TokenTracker(uint _restrictedShare) {
    // Throw if restricted share >= 100
    if (_restrictedShare >= 100) { throw; }
    
    restrictedShare = _restrictedShare;
  }
  
  /** 
   * PUBLIC functions
   *
   *  - isUnrestricted (getter)
   *  - multFracCeiling (library function)
   *  - isRegistered(addr) (getter)
   */
  
  /**
   * Return true iff the assignments are closed and there are no restricted
   * tokens left 
   */
  function isUnrestricted() constant returns (bool) {
    return (assignmentsClosed && totalRestrictedTokens == 0);
  }

  /**
   * Return the ceiling of (x*a)/b
   *
   * Edge cases:
   *   a = 0: return 0
   *   b = 0, a != 0: error (solidity throws on division by 0)
   */
  function multFracCeiling(uint x, uint a, uint b) returns (uint) {
    // Catch the case a = 0
    if (a == 0) { return 0; }
    
    // Rounding up is the same as adding 1-epsilon and rounding down.
    // 1-epsilon is modeled as (b-1)/b below.
    return (x * a + (b - 1)) / b; 
  }
    
  /**
   * Return true iff the address has tokens assigned (resp. restricted tokens)
   */
  function isRegistered(address addr, bool restricted) constant returns (bool) {
    if (restricted) {
      return (restrictions[addr] > 0);
    } else {
      return (tokens[addr] > 0);
    }
  }

  /**
   * INTERNAL functions
   *
   *  - assign
   *  - closeAssignments 
   *  - unrestrict 
   */
   
  /**
   * Assign (un)restricted tokens to given address
   */
  function assign(address addr, uint tokenAmount, bool restricted) internal {
    // Throw if assignments have been closed
    if (assignmentsClosed) { throw; }

    // Assign tokens
    tokens[addr] += tokenAmount;

    // Record restrictions and update total counters
    if (restricted) {
      totalRestrictedTokens += tokenAmount;
      totalRestrictedAssignments += 1;
      restrictions[addr] += tokenAmount;
    } else {
      totalUnrestrictedTokens += tokenAmount;
      totalUnrestrictedAssignments += 1;
    }
  }

  /**
   * Close future assignments.
   *
   * This is irreversible and closes all future assignments.
   * The function can only be called once.
   *
   * A call triggers the calculation of what fraction of restricted tokens
   * should be burned by subsequent calls to the unrestrict() function.
   * The result of this calculation is a multiplication factor whose nominator
   * and denominator are stored in the 