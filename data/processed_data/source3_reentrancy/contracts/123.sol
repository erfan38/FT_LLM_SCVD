contract Owned {
  address public owner;
  address private newOwner;

  event OwnershipTransferred(address indexed_from, address indexed_to);

  function Owned() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    newOwner = _newOwner;
  }

  function acceptOwnership() public {
    require(msg.sender == newOwner);
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0); //reset newOwner to 0/null
  }
}

/*
  Interface for being ERC223 compliant
  -ERC223 is an industry standard for smart contracts
*/
