contract DistrictBuyer {
  // Store the amount of ETH deposited by each account.
  mapping (address => uint256) public balances;
  // Bounty for executing buy.
  uint256 public bounty;
  // Track whether the 