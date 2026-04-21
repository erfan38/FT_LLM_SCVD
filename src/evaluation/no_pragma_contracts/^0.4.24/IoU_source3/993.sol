contract Marketplace {
 mapping(uint => uint) public itemPrices;

 function purchaseItem(uint itemId, uint quantity) public payable {
 uint totalCost = itemPrices[itemId] * quantity;
 require(msg.value >= totalCost, "Insufficient payment");
 }
}