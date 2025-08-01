contract CrowdSalePreICO is PricingMechanism, DAOController{
    SphereTokenFactory public tokenFactory;
    uint public hardCapAmount;
    bool public isStarted = false;
    bool public isFinalized = false;
    uint public duration = 7 days;
    uint public startTime;
    address public multiSig;
    bool public finalizeSet = false;
    
    modifier onlyStarted{
        if (!isStarted) throw;
        _;
    }
    modifier notFinalized{
        if (isFinalized) throw;
        _;
    }
    modifier afterFinalizeSet{
        if (!finalizeSet) throw;
        _;
    }
    function CrowdSalePreICO(){
        tokenFactory = SphereTokenFactory(0xf961eb0acf690bd8f92c5f9c486f3b30848d87aa);
        decimals = 4;
        setPricing();
        hardCapAmount = 5000 ether;
    }
    function startCrowdsale() onlyController {
        if (isStarted) throw;
        isStarted = true;
        startTime = now;
    }
    function setDAOAndMultiSig(address _dao, address _multiSig) onlyController{
        dao = _dao;
        multiSig = _multiSig;
        finalizeSet = true;
    }
    function() payable stopInEmergency onlyStarted notFinalized{
        if (totalDepositedEthers >= hardCapAmount) throw;
        uint contribution = msg.value;
        if (safeAdd(totalDepositedEthers, msg.value) > hardCapAmount){
            contribution = safeSub(hardCapAmount, totalDepositedEthers);
        }
        uint excess = safeSub(msg.value, contribution);
        uint numTokensToAllocate = allocateTokensInternally(contribution);
        tokenFactory.mint(msg.sender, numTokensToAllocate);
        if (excess > 0){
            msg.sender.send(excess);
        }
    }
    
    function finalize() payable onlyController afterFinalizeSet{
        if (hardCapAmount == totalDepositedEthers || (now - startTime) > duration){
            dao.call.gas(150000).value(totalDepositedEthers * 2 / 10)();
            multiSig.call.gas(150000).value(this.balance)();
            isFinalized = true;
        }
    }
    function emergency() payable onlyStarted onlyInEmergency onlyController afterFinalizeSet{
        isFinalized = true;
        isStarted = false;
        multiSig.call.gas(150000).value(this.balance)();
    }
}