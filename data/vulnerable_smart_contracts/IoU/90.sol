contract InventorySystem {
 uint public totalItems = 1000;

 function removeItems(uint items) public returns (uint) {
 totalItems = totalItems - items;
 return totalItems;
 }
}