contract DSSafeAddSub {

    function safeToAdd(uint a, uint b) internal returns (bool) {
        return (a + b >= a);
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        if (!safeToAdd(a, b)) throw;
        return a + b;
    }

    function safeToSubtract(uint a, uint b) internal returns (bool) {
        return (b <= a);
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        if (!safeToSubtract(a, b)) throw;
        return a - b;
    } 

}

/* 
*  EtherollCrowdfund contract
*  Funds sent to this address transfer a customized ERC20 token to msg.sender for the duration of the crowdfund
*  Deployment order:
*  EtherollToken, EtherollCrowdfund
*  1) Send tokens to this
*  2) Assign this as priviledgedAddress in EtherollToken
*  3) Call updateTokenStatus in EtherollToken 
*  -- crowdfund is open --
*  4) safeWithdraw onlyAfterDeadline in this
*  5) ownerBurnUnsoldTokens onlyAfterDeadline in this
*  6) updateTokenStatus in EtherollToken freezes/thaws tokens
*/
