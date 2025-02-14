pragma solidity ^0.4.24;




































contract DiceChainHelper is DiceChainBase {
    
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
    
    



    function setNewBidFee(uint256 _newBidFee) 
        external 
        onlyCEO 
        isHuman 
        isWithinLimits(_newBidFee) {
            
            bidFee = _newBidFee;
        }
    
    



    function setPlatformCut(uint256 _newPlatformCut)
        external
        onlyCEO
        isHuman {
            
            platformCut = _newPlatformCut;
            
        }

    



    function setPlatformCutPayout(uint256 _newPlatformCutPayout)
        external
        onlyCEO
        isHuman {
            
            platformCutPayout = _newPlatformCutPayout;
            
        }
        
    


    function setGasForOraclize(uint32 _newGasLimit)
        external
        onlyCEO
        isHuman {
            
            gasForOraclize = _newGasLimit;
            
        }
    
    


    function updateBalance()
        public
        payable
        onlyCEO
        isWithinLimits(msg.value) {
        
            emit balanceUpdated(msg.value);
        
        }

    


    function getBalance()
        public
        view
        returns (uint256) {

            return address(this).balance;

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
    
    


    function resetProgress()
        public
        returns (bool) {
            
            if (playerCurrentProgress[msg.sender] > 0) {
                
                playerCurrentProgress[msg.sender] = 0;
                
                playerAddressToBid[msg.sender] = 0;
                
                playerAddressToRollUnder[msg.sender] = 0;

                emit ResetProgress(
                    msg.sender, 
                    true
                );

                return true;
               
            } else {
                
                return false;
            }
            
        }
        
    


    function _resetProgress(address playerAddress)
        internal
        returns (uint256) {
            
            playerCurrentProgress[playerAddress] = 0;
            
            playerAddressToBid[playerAddress] = 0;
            
            playerAddressToRollUnder[playerAddress] = 0;
            
            return playerCurrentProgress[playerAddress];
            
        }
        
    
    


    function _calculatePayout(
        uint256 rollUnder,
        uint256 value)
        internal
        view
        isWithinLimits(value)
        returns (uint256) {
            
            require(rollUnder >= minRoll && rollUnder <= maxRoll, "invalid roll under number!");
            
            uint256 _totalPayout = 0 wei;
            
            _totalPayout = ((((value * (100-(SafeMath.sub(rollUnder,1)))) / (SafeMath.sub(rollUnder,1))+value))*platformCutPayout/platformCutPayoutDivisor)-value;
            
            return _totalPayout;
        }

    


    function getPlayerProgress()
    public
    view
    returns(uint256, uint256, uint256) {
        
        return (playerCurrentProgress[msg.sender], 
                playerAddressToBid[msg.sender], 
                playerAddressToRollUnder[msg.sender]);

    }
        
}

