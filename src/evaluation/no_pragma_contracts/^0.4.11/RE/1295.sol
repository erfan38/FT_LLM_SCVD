contract Haltable is Controlled {
  bool public halted;

  modifier stopInEmergency {
    if (halted) throw;
    _;
  }

  modifier onlyInEmergency {
    if (!halted) throw;
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function halt() external onlyController {
    halted = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function unhalt() external onlyController onlyInEmergency {
    halted = false;
  }

}

