contract Token {
  function balanceOf(address /*tokenOwner*/) public view returns (uint /*balance*/);
  function transfer(address /*to*/, uint /*tokens*/) public returns (bool /*success*/);
}

