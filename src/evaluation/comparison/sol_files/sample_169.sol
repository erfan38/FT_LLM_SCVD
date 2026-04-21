pragma solidity ^0.8.0;
function createNewDAO(address _newCurator) internal returns (MICRODAO _newDAO) {
NewCurator(_newCurator);
return daoCreator.createDAO(_newCurator, 0, 0, now + splitExecutionPeriod);
}