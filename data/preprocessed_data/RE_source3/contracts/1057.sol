contract owned {
  address public owner;

  function owned() { owner = msg.sender; }

  modifier onlyOwner {
    if (msg.sender != owner) { revert(); }
    _;
  }

  function changeOwner( address newowner ) onlyOwner {
    owner = newowner;
  }
}

// see https://www.ethereum.org/token
interface tokenRecipient {
  function receiveApproval( address from, uint256 value, bytes data );
}

// ERC223
interface ContractReceiver {
  function tokenFallback( address from, uint value, bytes data );
}

// ERC223-compliant token with ERC20 back-compatibility
//
// Implements:
// - https://theethereum.wiki/w/index.php/ERC20_Token_Standard
// - https://www.ethereum.org/token (uncontrolled, non-standard)
// - https://github.com/Dexaran/ERC23-tokens/blob/Recommended/ERC223_Token.sol

