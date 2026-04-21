contract CobinhoodBuyer {
  // Store the amount of ETH deposited by each account.
  mapping (address => uint256) public balances;
  // Track whether the 