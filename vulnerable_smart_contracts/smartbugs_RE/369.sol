






















contract HONG is HONGInterface, Token, TokenCreation {

    function HONG(
        address _managementBodyAddress,
        uint _closingTime,
        uint _closingTimeExtensionPeriod,
        uint _lastKickoffDateBuffer,
        uint _minTokensToCreate,
        uint _maxTokensToCreate,
        uint _tokensPerTier,
        bool _isInTestMode
    ) TokenCreation(_managementBodyAddress, _closingTime) {

        managementBodyAddress = _managementBodyAddress;
        closingTimeExtensionPeriod = _closingTimeExtensionPeriod;
        lastKickoffDateBuffer = _lastKickoffDateBuffer;

        minTokensToCreate = _minTokensToCreate;
        maxTokensToCreate = _maxTokensToCreate;
        tokensPerTier = _tokensPerTier;
        isInTestMode = _isInTestMode;

        returnWallet = new ReturnWallet(managementBodyAddress);
        rewardWallet = new RewardWallet(address(returnWallet));
        managementFeeWallet = new ManagementFeeWallet(managementBodyAddress, address(returnWallet));
        extraBalanceWallet = new ExtraBalanceWallet(address(returnWallet));

        if (address(extraBalanceWallet) == 0)
            doThrow("extraBalanceWallet:0");
        if (address(returnWallet) == 0)
            doThrow("returnWallet:0");
        if (address(rewardWallet) == 0)
            doThrow("rewardWallet:0");
        if (address(managementFeeWallet) == 0)
            doThrow("managementFeeWallet:0");
    }

    function () returns (bool success) {
        if (!isFromManagedAccount()) {
            
            return createTokenProxy(msg.sender);
        }
        else {
            evRecord(msg.sender, msg.value, "Recevied ether from ManagedAccount");
            return true;
        }
    }

    function isFromManagedAccount() internal returns (bool) {
        return msg.sender == address(extraBalanceWallet)
            || msg.sender == address(returnWallet)
            || msg.sender == address(rewardWallet)
            || msg.sender == address(managementFeeWallet);
    }

    


    function voteToKickoffNewFiscalYear() onlyTokenHolders noEther onlyLocked {
        
        
        uint _fiscal = currentFiscalYear + 1;

        if(!isKickoffEnabled[1]){  
            

        }else if(currentFiscalYear <= 3){  

            if(lastKickoffDate + lastKickoffDateBuffer < now){ 
                
            }else{
                
                doThrow("kickOff:tooEarly");
                return;
            }
        }else{
            
            doThrow("kickOff:4thYear");
            return;
        }


        supportKickoffQuorum[_fiscal] -= votedKickoff[_fiscal][msg.sender];
        supportKickoffQuorum[_fiscal] += balances[msg.sender];
        votedKickoff[_fiscal][msg.sender] = balances[msg.sender];


        uint threshold = (kickoffQuorumPercent*(tokensCreated + bountyTokensCreated)) / 100;
        if(supportKickoffQuorum[_fiscal] > threshold) {
            if(_fiscal == 1){
                
                extraBalanceWallet.returnBalanceToMainAccount();

                
                totalInitialBalance = this.balance;
                uint fundToReserve = (totalInitialBalance * mgmtFeePercentage) / 100;
                annualManagementFee = fundToReserve / 4;
                if(!managementFeeWallet.send(fundToReserve)){
                    doThrow("kickoff:ManagementFeePoolWalletFail");
                    return;
                }

            }
            isKickoffEnabled[_fiscal] = true;
            currentFiscalYear = _fiscal;
            lastKickoffDate = now;

            
            managementFeeWallet.payManagementBodyAmount(annualManagementFee);

            evKickoff(msg.sender, msg.value, _fiscal);
            evIssueManagementFee(msg.sender, msg.value, annualManagementFee, true);
        }
    }

    function voteToFreezeFund() onlyTokenHolders noEther onlyLocked notFinalFiscalYear onlyDistributionNotInProgress {

        supportFreezeQuorum -= votedFreeze[msg.sender];
        supportFreezeQuorum += balances[msg.sender];
        votedFreeze[msg.sender] = balances[msg.sender];

        uint threshold = ((tokensCreated + bountyTokensCreated) * freezeQuorumPercent) / 100;
        if(supportFreezeQuorum > threshold){
            isFreezeEnabled = true;
            distributeDownstream(0);
            evFreeze(msg.sender, msg.value);
        }
    }

    function recallVoteToFreezeFund() onlyTokenHolders onlyNotFrozen noEther {
        supportFreezeQuorum -= votedFreeze[msg.sender];
        votedFreeze[msg.sender] = 0;
    }

    function voteToHarvestFund() onlyTokenHolders noEther onlyLocked onlyFinalFiscalYear {

        supportHarvestQuorum -= votedHarvest[msg.sender];
        supportHarvestQuorum += balances[msg.sender];
        votedHarvest[msg.sender] = balances[msg.sender];

        uint threshold = ((tokensCreated + bountyTokensCreated) * harvestQuorumPercent) / 100;
        if(supportHarvestQuorum > threshold) {
            isHarvestEnabled = true;
            evHarvest(msg.sender, msg.value);
        }
    }

    function collectMyReturn() onlyTokenHolders noEther onlyDistributionReady {
        uint tokens = balances[msg.sender];
        balances[msg.sender] = 0;
        returnWallet.payTokenHolderBasedOnTokenCount(msg.sender, tokens);
    }

    function mgmtInvestProject(
        address _projectWallet,
        uint _amount
    ) onlyManagementBody hasEther returns (bool _success) {

        if(!isKickoffEnabled[currentFiscalYear] || isFreezeEnabled || isHarvestEnabled){
            evMgmtInvestProject(msg.sender, msg.value, _projectWallet, _amount, false);
            return;
        }

        if(_amount >= this.balance){
            doThrow("failed:mgmtInvestProject: amount >= actualBalance");
            return;
        }

        
        if (!_projectWallet.call.value(_amount)()) {
            doThrow("failed:mgmtInvestProject: cannot send to _projectWallet");
            return;
        }

        evMgmtInvestProject(msg.sender, msg.value, _projectWallet, _amount, true);
    }

    function transfer(address _to, uint256 _value) returns (bool success) {

        
        if(currentFiscalYear < 4){
            if(votedKickoff[currentFiscalYear+1][msg.sender] > _value){
                votedKickoff[currentFiscalYear+1][msg.sender] -= _value;
                supportKickoffQuorum[currentFiscalYear+1] -= _value;
            }else{
                supportKickoffQuorum[currentFiscalYear+1] -= votedKickoff[currentFiscalYear+1][msg.sender];
                votedKickoff[currentFiscalYear+1][msg.sender] = 0;
            }
        }

        
        if(votedFreeze[msg.sender] > _value){
            votedFreeze[msg.sender] -= _value;
            supportFreezeQuorum -= _value;
        }else{
            supportFreezeQuorum -= votedFreeze[msg.sender];
            votedFreeze[msg.sender] = 0;
        }

        if(votedHarvest[msg.sender] > _value){
            votedHarvest[msg.sender] -= _value;
            supportHarvestQuorum -= _value;
        }else{
            supportHarvestQuorum -= votedHarvest[msg.sender];
            votedHarvest[msg.sender] = 0;
        }

        if (isFundLocked && super.transfer(_to, _value)) {
            return true;
        } else {
            if(!isFundLocked){
                doThrow("failed:transfer: isFundLocked is false");
            }else{
                doThrow("failed:transfer: cannot send send to _projectWallet");
            }
            return;
        }
    }
}