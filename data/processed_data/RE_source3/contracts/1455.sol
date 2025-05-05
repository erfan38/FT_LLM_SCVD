contract Phased {
  /**
   * Array of transition times defining the phases
   *   
   * phaseEndTime[i] is the time when phase i has just ended.
   * Phase i is defined as the following time interval: 
   *   [ phaseEndTime[i-1], * phaseEndTime[i] )
   */
  uint[] public phaseEndTime;

  /**
   * Number of phase transitions N = phaseEndTime.length 
   *
   * There are N+1 phases, numbered 0,..,N.
   * The first phase has no start and the last phase has no end.
   */
  uint public N; 

  /**
   *  Maximum delay for phase transitions
   *
   *  maxDelay[i] is the maximum amount of time by which the transition
   *  phaseEndTime[i] can be delayed.
  */
  mapping(uint => uint) public maxDelay; 

  /*
   * The 