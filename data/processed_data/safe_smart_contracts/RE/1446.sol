contract FDC is TokenTracker, Phased, StepFunction, Targets, Parameters {
  // An identifying string, set by the constructor
  string public name;
  
  /*
   * Phases
   *
   * The FDC over its lifetime runs through a number of phases. These phases are
   * tracked by the base 