contract EnergySystem {
 uint public totalEnergy = 1000;

 function consumeEnergy(uint amount) public returns (uint) {
 totalEnergy = totalEnergy - amount;
 return totalEnergy;
 }
}