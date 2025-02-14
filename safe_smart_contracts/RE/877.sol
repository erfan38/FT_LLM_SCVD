contract Ownable {

  address public owner;


  function Ownable() {
    owner = msg.sender;
  }

  /*
  Throws if called by any account other than the owner.
  */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /*
  Allows the current owner to transfer control of the 