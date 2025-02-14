contract EtherollCrowdfund is owned, DSSafeAddSub {

    /*
    *  checks only after crowdfund deadline
    */    
    modifier onlyAfterDeadline() { 
        if (now < deadline) throw;
        _; 
    }

    /*
    *  checks only in emergency
    */    
    modifier isEmergency() { 
        if (!emergency) throw;
        _; 
    } 

    /* the crowdfund goal */
    uint public fundingGoal;
    /* 1 week countdown to price increase */
    uint public weekTwoPriceRiseBegin = now + 10080 * 1 minutes;    
    /* 80% to standard multi-sig wallet 