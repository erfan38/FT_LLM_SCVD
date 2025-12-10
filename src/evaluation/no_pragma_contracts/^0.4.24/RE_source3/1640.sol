contract CheckpointToken is ERC677Token {
  using SafeMath for uint256; // We use only uint256 for safety reasons (no boxing)

  /// @dev Name of the token, usually the company and/or series (like "TokenMeerkat Ltd. Series A"):
  string public name;
  /// @dev Ticker symbol, usually bases on the "name" above (like "MEER"):
  string public symbol;
  /// @dev Decimals are usually set to 18 for EIP-20 tokens:
  uint256 public decimals;
  /// @dev If transactionVerifier is set, that 