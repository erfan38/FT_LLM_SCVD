contract Authorizable is Ownable {
  mapping(address => bool) public authorized;
  
  event AuthorizationSet(address indexed addressAuthorized, bool indexed authorization);

  /**
   * @dev The Authorizable constructor sets the first `authorized` of the 