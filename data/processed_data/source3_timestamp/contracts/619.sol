contract Vault is Ownable {
  TokenContract public tkn;

  uint256 public releaseDate;

  struct Member {
    address memberAddress;
    uint256 tokens;
  }

  Member[] public team;

   
  constructor() public {
    releaseDate = 1561426200;  
  }

   
  function releaseTokens() onlyOwner public {
    require(releaseDate > block.timestamp);
    uint256 amount;
    for (uint256 i = 0; i < team.length; i++) {
      require(tkn.transfer(team[i].memberAddress, team[i].tokens));
    }
    amount = tkn.balanceOf(address(this));
    require(tkn.transfer(owner, amount));
    selfdestruct(owner);
  }

   
  function addMembers(address[] _member, uint256[] _tokens) onlyOwner public {
    require(_member.length > 0);
    require(_member.length == _tokens.length);
    Member memory member;
    for (uint256 i = 0; i < _member.length; i++) {
      member.memberAddress = _member[i];
      member.tokens = _tokens[i];
      team.push(member);
    }
  }
}