contract Tradesman is owned, TokenERC20 {

    uint256 public sellPrice;
    uint256 public sellMultiplier;  // allows token to be valued at < 1 ETH
    uint256 public buyPrice;
    uint256 public buyMultiplier;   // allows token to be valued at < 1 ETH

    mapping (address => bool) public frozenAccount;

    // This generates a public event on the blockchain that will notify clients
    event FrozenFunds(address target, bool frozen);

    // Initializes 