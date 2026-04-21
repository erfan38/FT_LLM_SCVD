pragma solidity ^0.4.24;




































contract PowerEtherHelper is PowerEtherBase {
    
    using SafeMath for *;
    using strings for *;
    
    








    
    


    function activate() 
        external 
        onlyCEO {
            
            require(msg.sender != address(0));
        
            activated_ = !activated_;
        }
    
    

    
    function deactivate() 
        external 
        onlyCEO {
            
            require(msg.sender != address(0));
        
            activated_ = false;
        }
    
    


    function setCEO(address _newCEO) 
        external 
        onlyCEO 
        isHuman {
            
            require(_newCEO != address(0));

            ceoAddress = _newCEO;
        }
    
    



    function setPowerOneBidPrice(uint256 _newBid) 
        external 
        onlyCEO 
        isHuman 
        isWithinLimits(_newBid) {
            
            powerOneBid = _newBid;
        }
    
    



    function setPowerOneFeePrice(uint256 _newFee) 
        external 
        onlyCEO 
        isHuman 
        isWithinLimits(_newFee) {
            
            powerOneFee = _newFee;
        }
    
    



    function setPowerTwoBidPrice(uint256 _newBid) 
        external 
        onlyCEO 
        isHuman 
        isWithinLimits(_newBid) {
            
            powerTwoBid = _newBid;
        }
    
    



    function setPowerTwoFeePrice(uint256 _newFee) 
        external 
        onlyCEO 
        isHuman 
        isWithinLimits(_newFee) {
            
            powerTwoFee = _newFee;
        }
    
    



    function setPowerFourBidPrice(uint256 _newBid) 
        external 
        onlyCEO 
        isHuman 
        isWithinLimits(_newBid) {
            
            powerFourBid = _newBid;
        }
    
    



    function setPowerFourFeePrice(uint256 _newFee) 
        external 
        onlyCEO 
        isHuman 
        isWithinLimits(_newFee) {
            
            powerFourFee = _newFee;
        }
    
    



    function setPlatformCut(uint256 _newPlatformCut)
        external
        onlyCEO
        isHuman {
            
            platformCut = _newPlatformCut;
            
        }
    
    



    function setMegaJackpotCap(uint256 _newCap)
        external
        onlyCEO
        isHuman {
            
            megaJackpotCap = _newCap;
            
        }
        
    


    function setMegaJackpotFee(uint256 _newMegaJackpotFee)
        external
        onlyCEO
        isHuman {
            
            megaJackpotFee = _newMegaJackpotFee;
            
        }
        
    


    function setGasForOraclize(uint32 _newGasLimit)
        external
        onlyCEO
        isHuman {
            
            gasForOraclize = _newGasLimit;
            
        }
        
    


    function setMinNumber(uint256 _newMinNumber)
        external
        onlyCEO
        isHuman {
            
            minNumber = _newMinNumber;
            
        }
    
    


    function setMaxNumber(uint256 _newMaxNumber)
        external
        onlyCEO
        isHuman {
            
            maxNumber = _newMaxNumber;
            
        }
    
    


    function _checkTwo(
        uint256 _resultNumberOne,
        uint256 _resultNumberTwo,
        uint256 _powerNumberOne,
        uint256 _powerNumberTwo
        ) 
        internal 
        returns (bool) {
            if ((_resultNumberOne == _powerNumberOne ||
                _resultNumberOne == _powerNumberTwo) &&
                (_resultNumberTwo == _powerNumberOne ||
                _resultNumberTwo == _powerNumberTwo)
                ) {
                    return (true);
                } else {
                    return (false);
                }
        }
    
    


    function _checkFour(
        uint256 _resultNumberOne,
        uint256 _resultNumberTwo,
        uint256 _resultNumberThree,
        uint256 _resultNumberFour,
        uint256 _powerNumberOne,
        uint256 _powerNumberTwo,
        uint256 _powerNumberThree,
        uint256 _powerNumberFour
        )
        internal
        returns (bool) {
            if ((_resultNumberOne == _powerNumberOne ||
                _resultNumberOne == _powerNumberTwo ||
                _resultNumberOne == _powerNumberThree ||
                _resultNumberOne == _powerNumberFour) &&
                (_resultNumberTwo == _powerNumberOne ||
                _resultNumberTwo == _powerNumberTwo ||
                _resultNumberTwo == _powerNumberThree ||
                _resultNumberTwo == _powerNumberFour) &&
                (_resultNumberThree == _powerNumberOne ||
                _resultNumberThree == _powerNumberTwo ||
                _resultNumberThree == _powerNumberThree ||
                _resultNumberThree == _powerNumberFour) &&
                (_resultNumberFour == _powerNumberOne ||
                _resultNumberFour == _powerNumberTwo ||
                _resultNumberFour == _powerNumberThree ||
                _resultNumberFour == _powerNumberFour)) {
                    return true;
                } else {
                    return false;
                }
        }
        
    



    function collectFees()
        external
        onlyCEO
        isHuman {
            
            uint256 powerOnePayouts = SafeMath.mul(powerOneFee, powerOneFeesToCollect);
            uint256 powerTwoPayouts = SafeMath.mul(powerTwoFee, powerTwoFeesToCollect);
            uint256 powerFourPayouts = SafeMath.mul(powerFourFee, powerFourFeesToCollect);
            
            uint256 totalOneTwo = SafeMath.add(powerOnePayouts, powerTwoPayouts);
            uint256 totalAll = SafeMath.add(totalOneTwo, powerFourPayouts);
            
            require(totalAll <= address(this).balance, "Insufficient funds!");
            
            ceoAddress.transfer(totalAll);
            
            
            powerOneFeesToCollect = 0;
            powerTwoFeesToCollect = 0;
            powerFourFeesToCollect = 0;
            
        }
    
    



    function _checkMegaJackpotCap(address playerAddress) 
        internal
        returns (bool) {
            
        
        if (megaJackpot >= megaJackpotCap) {
                    
        require(megaJackpot <= address(this).balance, "Insufficient funds!");
                    
        uint256 megaJackpotPayout = SafeMath.div(SafeMath.mul(megaJackpot, platformCut), 100);
        uint256 platformMegaCutPayout = SafeMath.sub(megaJackpot, megaJackpotPayout);
                        
        emit MegaJackpotCapWin(
            playerAddress,
            megaJackpotPayout
        );
                    
        playerAddress.transfer(megaJackpotPayout);
        ceoAddress.transfer(platformMegaCutPayout);
                    
        megaJackpot = 0;
        megaJackpotWinCount ++;

        totalEtherWon += megaJackpotPayout;

        return true;
                    
        }
        return false;
    }
    
    


    function updateBalance(uint256 etherToAdd)
        public
        payable
        onlyCEO {
        
            emit balanceUpdated(etherToAdd);
        
        }
    
    


    function updatePowerOneBalance(uint256 etherToAdd)
        public
        payable
        onlyCEO {
            
            powerOneJackpot += etherToAdd;
            emit balanceUpdated(etherToAdd);
        
        }
    
    


    function updatePowerTwoBalance(uint256 etherToAdd)
        public
        payable
        onlyCEO {
            
            powerTwoJackpot += etherToAdd;
            emit balanceUpdated(etherToAdd);
        
        }
    
    


    function updatePowerFourBalance(uint256 etherToAdd)
        public
        payable
        onlyCEO {
            
            powerFourJackpot += etherToAdd;
            emit balanceUpdated(etherToAdd);
        
        }
    
    


    function withdrawPendingTransactions() 
        public 
        isHuman
        isActivated
        returns (bool) {
            
            uint256 amount = playerFundsToWithdraw[msg.sender];
            
            playerFundsToWithdraw[msg.sender] = 0;
        
            if (msg.sender.call.value(amount)()) {
                
                return true;
                
            } else {
            
            
            playerFundsToWithdraw[msg.sender] = amount;
            
            return false;
        }
    }
    
    



    function getPendingTransactions(address playerAddress) 
        public 
        constant 
        returns (uint256) {
            
            return playerFundsToWithdraw[playerAddress];
        }
    
}

