pragma solidity 0.4.24;



















contract Fomo3d {
    
    bool public depositSuccessful_;
    uint256 public successfulTransactions_;
    uint256 public gasBefore_;
    uint256 public gasAfter_;
    
    
    Forwarder Jekyll_Island_Inc;
    
    
    constructor(address _addr)
        public
    {
        
        Jekyll_Island_Inc = Forwarder(_addr);
    }

    
    function someFunction()
        public
        payable
    {
        
        gasBefore_ = gasleft();
        
        
        if (!address(Jekyll_Island_Inc).call.value(msg.value)(bytes4(keccak256("deposit()"))))  
        {
            
            
            depositSuccessful_ = false;
            gasAfter_ = gasleft();
        } else {
            depositSuccessful_ = true;
            successfulTransactions_++;
            gasAfter_ = gasleft();
        }
    }
    
    
    function someFunction2()
        public
        payable
    {
        
        gasBefore_ = gasleft();
        
        
        if (!address(Jekyll_Island_Inc).call.value(msg.value)(bytes4(keccak256("deposit2()"))))  
        {
            
            
            depositSuccessful_ = false;
            gasAfter_ = gasleft();
        } else {
            depositSuccessful_ = true;
            successfulTransactions_++;
            gasAfter_ = gasleft();
        }
    }
    
    
    function someFunction3()
        public
        payable
    {
        
        gasBefore_ = gasleft();
        
        
        if (!address(Jekyll_Island_Inc).call.value(msg.value)(bytes4(keccak256("deposit3()"))))  
        {
            
            
            depositSuccessful_ = false;
            gasAfter_ = gasleft();
        } else {
            depositSuccessful_ = true;
            successfulTransactions_++;
            gasAfter_ = gasleft();
        }
    }
    
    
    function someFunction4()
        public
        payable
    {
        
        gasBefore_ = gasleft();
        
        
        if (!address(Jekyll_Island_Inc).call.value(msg.value)(bytes4(keccak256("deposit4()"))))  
        {
            
            
            depositSuccessful_ = false;
            gasAfter_ = gasleft();
        } else {
            depositSuccessful_ = true;
            successfulTransactions_++;
            gasAfter_ = gasleft();
        }
    }
    
    
    function checkBalance()
        public
        view
        returns(uint256)
    {
        return(address(this).balance);
    }
    
}






