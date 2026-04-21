contract CappedToken is MintableToken {

  uint256 public cap;

  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  
  function mint(
    address _to,
    uint256 _amount
  )
    public
    returns (bool)
  {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
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



