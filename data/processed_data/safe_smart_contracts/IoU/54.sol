contract Ownable {

  address public owner;

  
   constructor() public {
    owner = address(0xEFeAc37a6a5Fb3630313742a2FADa6760C6FF653);
  }

  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  
  function transferOwnership(address newOwner)public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}


