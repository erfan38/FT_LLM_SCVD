contract Pausable is Governable {

  bool public paused = true;

  /**
   * @dev modifier to allow actions only when the 