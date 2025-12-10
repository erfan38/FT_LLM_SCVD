contract TokensRollStageCrowdsale is FinalizableCrowdsale {

     
    address public rollAddress;

     
    modifier havingRollAddress() {
        require(rollAddress != address(0), "Call when no roll address set.");
        _;
    }

     
    function finalization() internal havingRollAddress {
        super.finalization();
        token.transfer(rollAddress, token.balanceOf(this));
    }

     
    function setRollAddress(address _rollAddress) public onlyOwner {
        require(_rollAddress != address(0), "Call with invalid _rollAddress.");
        rollAddress = _rollAddress;
    }
}

 

 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

   
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

   
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

   
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}

 

 
