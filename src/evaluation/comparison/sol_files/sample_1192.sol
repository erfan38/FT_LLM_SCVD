pragma solidity ^0.8.0;
}

interface CompetitionInterface {



event Register(uint withId, address fund, address manager);
event ClaimReward(address registrant, address fund, uint shares);



function termsAndConditionsAreSigned(address byManager, uint8 v, bytes32 r, bytes32 s) view returns (bool);