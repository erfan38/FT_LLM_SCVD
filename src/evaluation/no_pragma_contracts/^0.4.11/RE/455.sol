contract Startable is Ownable, Authorizable {
  event Start();

  bool public started = false;

  /**
   * @dev Modifier to make a function callable only when the 