pragma solidity ^0.8.0;
struct Player {
address owneraddress;
}

Player[] players;
bool gameStarted;

GameConfigInterface public schema;


mapping(address => mapping(uint256 => uint256)) public unitsOwned;
mapping(address => mapping(uint256 => uint256)) public upgradesOwned;

mapping(address => uint256) public uintsOwnerCount;
mapping(address=> mapping(uint256 => uint256)) public uintProduction;


mapping(address => mapping(uint256 => uint256)) public unitCoinProductionIncreases;
mapping(address => mapping(uint256 => uint256)) public unitCoinProductionMultiplier;
mapping(address => mapping(uint256 => uint256)) public unitAttackIncreases;
mapping(address => mapping(uint256 => uint256)) public unitAttackMultiplier;
mapping(address => mapping(uint256 => uint256)) public unitDefenseIncreases;
mapping(address => mapping(uint256 => uint256)) public unitDefenseMultiplier;
mapping(address => mapping(uint256 => uint256)) public unitJadeStealingIncreases;
mapping(address => mapping(uint256 => uint256)) public unitJadeStealingMultiplier;
mapping(address => mapping(uint256 => uint256)) private unitMaxCap;


function setConfigAddress(address _address) external onlyOwner {
schema = GameConfigInterface(_address);
}