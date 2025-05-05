contract DeltaBalances {
    
  address public admin; 

  function DeltaBalances() public {
    admin = msg.sender;
  }

  // Fallback function, don't accept any ETH
  function() public payable {
    revert();
  }

  // Limit withdrawals to the 