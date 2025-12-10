contract ResourceManager {
 uint public totalResources = 1000000;

 function harvestResources(uint amount, uint maxHarvest) public returns (uint) {
 require(amount <= maxHarvest);
 totalResources = totalResources + amount;
 return totalResources;
 }
}