contract Targets {

  // Mapping from counter id to counter value 
  mapping(uint => uint) public counter;
  
  // Mapping from counter id to target value 
  mapping(uint => uint) public target;

  // A public getter that returns whether the target was reached
  function targetReached(uint id) constant returns (bool) {
    return (counter[id] >= target[id]);
  }
  
  /*
   * Modifying counter or target are internal functions.
   */
  
  // (Re-)set the target
  function setTarget(uint id, uint _target) internal {
    target[id] = _target;
  }
 
  // Add to the counter 
  // The function returns whether this current addition makes the counter reach
  // or cross its target value 
  function addTowardsTarget(uint id, uint amount) 
    internal 
    returns (bool firstReached) 
  {
    firstReached = (counter[id] < target[id]) && 
                   (counter[id] + amount >= target[id]);
    counter[id] += amount;
  }
}

// import "Parameters.sol";

/**
 * title:  Configuration parameters for the FDC
 * author: Timo Hanke 
 */

