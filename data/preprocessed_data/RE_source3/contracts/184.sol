contract Pausable is Ownable {
  event Pause();
  event Unpause();
  event FinalUnpause();
  
  bool public paused = false;
  // finalUnpaused always false, not sure its purpose
  bool public finalUnpaused = false;

  /**
   * @dev Modifier to make a function callable only when the 